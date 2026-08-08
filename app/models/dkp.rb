raise "DKP_DATABASE_URL is not set" if DKP_DB.nil?

module Dkp
  class Attendee < Sequel::Model(DKP_DB[:attendees])
    many_to_one :event, class: "Dkp::Event"
  end

  class Character < Sequel::Model(DKP_DB[:characters])
    one_to_many :event_loots, class: "Dkp::EventLoot", key: :character_id
    one_to_many :ftes, class: "Dkp::Fte", key: :character_id
    one_to_many :removals, class: "Dkp::Removal", key: :character_id
    one_to_many :rewards, class: "Dkp::Reward", key: :character_id
    one_to_many :trackings, class: "Dkp::Tracking", key: :character_id
  end

  class Cheevo < Sequel::Model(DKP_DB[:cheevos])
  end

  class EqdkpEvent < Sequel::Model(DKP_DB[:eqdkp_events])
  end

  class EventLoot < Sequel::Model(DKP_DB[:event_loots])
    many_to_one :event, class: "Dkp::Event"
    many_to_one :loot, class: "Dkp::Loot"
    many_to_one :item, class: "Dkp::Item"
    many_to_one :character, class: "Dkp::Character"
    many_to_one :attendee, class: "Dkp::Attendee"
  end

  class Event < Sequel::Model(DKP_DB[:events])
    many_to_one :target, class: "Dkp::Target"
    one_to_many :attendees, class: "Dkp::Attendee", key: :event_id
    one_to_many :event_loots, class: "Dkp::EventLoot", key: :event_id
    one_to_many :ftes, class: "Dkp::Fte", key: :event_id
    one_to_many :removals, class: "Dkp::Removal", key: :event_id
    one_to_many :trackings, class: "Dkp::Tracking", key: :event_id
  end

  class Fte < Sequel::Model(DKP_DB[:ftes])
    many_to_one :event, class: "Dkp::Event"
    many_to_one :character, class: "Dkp::Character"
  end

  class Item < Sequel::Model(DKP_DB[:items])
    one_to_many :loots, class: "Dkp::Loot", key: :item_id
    one_to_many :loot_tables, class: "Dkp::LootTable", key: :item_id
    one_to_many :event_loots, class: "Dkp::EventLoot", key: :item_id

    SUGGESTION_LIMIT = 25

    # Exact name lookup (case-insensitive; ` and ' are interchangeable).
    # Returns a single item payload on success, or raises AmbiguousItemError /
    # ItemNotFoundError with suggested name variations when the query is not exact.
    def self.find_exact_with_dkp!(query)
      q = query.to_s.strip
      raise ItemNotFoundError.new(q, []) if q.empty?

      exact = exact_name_matches(q)
      if exact.length == 1
        return item_with_dkp(exact.first)
      end

      if exact.length > 1
        raise AmbiguousItemError.new(q, exact.map(&:name).uniq.sort)
      end

      suggestions = similar_item_names(q)
      if suggestions.empty?
        raise ItemNotFoundError.new(q, [])
      end

      raise AmbiguousItemError.new(q, suggestions)
    end

    def self.normalize_quotes(value)
      value.to_s.tr("`", "'")
    end

    def self.exact_name_matches(query)
      normalized = normalize_quotes(query).downcase
      normalized_name = Sequel.function(
        :lower,
        Sequel.function(:replace, Sequel[:items][:name], "`", "'")
      )
      where(normalized_name => normalized).order(:name).all
    end

    def self.similar_item_names(query)
      escaped = normalize_quotes(query).gsub(/([%_\\])/) { |char| "\\#{char}" }
      normalized_name = Sequel.function(:replace, Sequel[:items][:name], "`", "'")
      where(Sequel.ilike(normalized_name, "%#{escaped}%"))
        .order(:name)
        .limit(SUGGESTION_LIMIT)
        .select_map(:name)
    end

    def self.item_with_dkp(item)
      stats = where(Sequel[:items][:id] => item.id)
        .left_join(:event_loots, item_id: Sequel[:items][:id])
        .select(
          Sequel[:items][:id],
          Sequel[:items][:name],
          Sequel.function(:count, Sequel[:event_loots][:id]).as(:times_awarded),
          Sequel.function(:coalesce, Sequel.function(:sum, Sequel[:event_loots][:dkp]), 0).as(:total_dkp),
          Sequel.function(:min, Sequel[:event_loots][:dkp]).as(:min_dkp),
          Sequel.function(:max, Sequel[:event_loots][:dkp]).as(:max_dkp),
          Sequel.function(:avg, Sequel[:event_loots][:dkp]).as(:average_dkp)
        )
        .group(Sequel[:items][:id], Sequel[:items][:name])
        .first

      awards = EventLoot
        .where(item_id: item.id)
        .eager(:character, event: :target)
        .order(Sequel.desc(:created_at), Sequel.desc(:id))
        .all

      times = stats[:times_awarded].to_i
      {
        id: stats.id,
        name: stats.name,
        summary: {
          times_awarded: times,
          total_dkp: stats[:total_dkp].to_i,
          average_dkp: times.zero? ? nil : stats[:average_dkp].to_f.round(2),
          min_dkp: stats[:min_dkp],
          max_dkp: stats[:max_dkp]
        },
        awards: awards.map { |award| award_payload(award) }
      }
    end

    def self.award_payload(award)
      character = award.character
      event = award.event
      target = event && event.target

      {
        id: award.id,
        dkp: award.dkp,
        awarded_at: award.created_at && award.created_at.iso8601,
        character: character && {
          id: character.id,
          name: character.name,
          class: character.klass
        },
        event: event && {
          id: event.id,
          name: event.name,
          target: target && {
            id: target.id,
            name: target.name
          }
        }
      }
    end
    private_class_method :award_payload, :exact_name_matches, :similar_item_names, :item_with_dkp, :normalize_quotes
  end

  class ItemLookupError < StandardError
    attr_reader :query, :matches

    def initialize(query, matches)
      @query = query
      @matches = matches
      super(message_for(query, matches))
    end

    def to_h
      {
        error: message,
        query: query,
        matches: matches
      }
    end
  end

  class AmbiguousItemError < ItemLookupError
    def message_for(_query, matches)
      "No exact unique item match; refine your query. Found #{matches.length} variation(s)."
    end
  end

  class ItemNotFoundError < ItemLookupError
    def message_for(query, _matches)
      "No item found matching #{query.inspect}"
    end
  end


  class LootTable < Sequel::Model(DKP_DB[:loot_tables])
    many_to_one :item, class: "Dkp::Item"
    many_to_one :target, class: "Dkp::Target"
  end

  class Loot < Sequel::Model(DKP_DB[:loots])
    many_to_one :item, class: "Dkp::Item"
  end

  class Permission < Sequel::Model(DKP_DB[:permissions])
  end

  class Removal < Sequel::Model(DKP_DB[:removals])
    many_to_one :event, class: "Dkp::Event"
    many_to_one :character, class: "Dkp::Character"
  end

  class Reward < Sequel::Model(DKP_DB[:rewards])
    many_to_one :character, class: "Dkp::Character"
  end

  class TargetAlias < Sequel::Model(DKP_DB[:target_aliases])
    many_to_one :target, class: "Dkp::Target"
  end

  class Target < Sequel::Model(DKP_DB[:targets])
    many_to_one :tier, class: "Dkp::Tier"
    one_to_many :events, class: "Dkp::Event", key: :target_id
    one_to_many :target_aliases, class: "Dkp::TargetAlias", key: :target_id
    one_to_many :loot_tables, class: "Dkp::LootTable", key: :target_id
    one_to_many :trackings, class: "Dkp::Tracking", key: :target_id
  end

  class Tier < Sequel::Model(DKP_DB[:tiers])
    one_to_many :targets, class: "Dkp::Target", key: :tier_id
  end

  class Tracking < Sequel::Model(DKP_DB[:trackings])
    many_to_one :target, class: "Dkp::Target"
    many_to_one :character, class: "Dkp::Character"
    many_to_one :event, class: "Dkp::Event"
    many_to_one :on_character, class: "Dkp::Character", key: :on_character_id
  end
end
