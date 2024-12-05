# frozen_string_literal: true

class Event < ApplicationRecord
  include Nostr::Nip1

  scope :of_pubkey, ->(pubkey) { where(pubkey:) }
  scope :of_session, ->(session) { where(session:) }
  scope :of_topic, ->(topic) { where(topic:) }
  scope :of_recipient, ->(recipient) { where(recipient:) }

  belongs_to :conversation, foreign_key: %i[pubkey session], required: true, autosave: true
  has_one :merkle_node, dependent: :restrict_with_exception

  # A publisher must not send events in the same time which makes harder to sort them.
  validates :created_at,
            presence: true
  validates :created_at,
            comparison: {
              greater_than_or_equal_to: ->(current) {
                current.conversation&.latest_event_created_at || 0
              }
            },
            if: :new_record?

  validates :session,
            presence: true,
            length: { maximum: 4 }

  validates :topic,
            length: { is: 64 },
            format: { with: /\A\h+\z/ },
            allow_nil: true

  validates :recipient,
            length: { is: 64 },
            format: { with: /\A\h+\z/ },
            allow_nil: true

  validate if: :new_record? do
    prev_id = tags.find { |tag| tag[0] == "prev_id" }&.[](1)
    next if prev_id.blank?

    if self.connection.latest_eid != prev_id
      errors.add :prev_id, :invalid
    end
  end

  before_validation on: :create do
    self.session = tags.find { |tag| tag[0] == "s" }&.[](1)
    self.topic = tags.find { |tag| tag[0] == "t" }&.[](1)
    self.recipient = tags.find { |tag| tag[0] == "p" }&.[](1)

    self.conversation ||= Conversation.find_or_create_by(pubkey: pubkey, session: session) do |c|
      c.latest_event_created_at = created_at
      c.events_count = 0
    end
  end

  after_validation on: :create do
    self.conversation.latest_eid = eid
    self.conversation.latest_event_created_at = created_at
    self.conversation.events_count += 1
  end

  after_create :add_to_merkle_tree

  def merkle_tree_hash
    Digest::Keccak256.digest([pubkey, topic, session].join)
  end

  def merkle_tree_root
    merkle_node&.tree_root
  end

  def consistency_proof
    merkle_node&.consistency_proof
  end

  def inclusion_proof
    merkle_node&.inclusion_proof
  end

  def readonly?
    persisted?
  end

  class << self
    def from_raw(nip1_json)
      return new unless nip1_json

      new(
        eid: nip1_json.fetch("id"),
        pubkey: nip1_json.fetch("pubkey"),
        created_at: nip1_json.fetch("created_at"),
        kind: nip1_json.fetch("kind"),
        tags: nip1_json.fetch("tags"),
        content: nip1_json.fetch("content"),
        sig: nip1_json.fetch("sig")
      )
    end
  end

  private

  def add_to_merkle_tree
    return if new_record?
    return if MerkleNode.where(event: self).exists?

    lock_key = "add_to_merkle_tree_#{merkle_tree_hash}"
    with_advisory_lock(lock_key) do
      MerkleNode.push_leaves!([self])
      MerkleNode.untaint!(merkle_tree_hash)
    end
  end
end
