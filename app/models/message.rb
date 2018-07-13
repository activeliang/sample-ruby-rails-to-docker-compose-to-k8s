class Message < ApplicationRecord
  after_create_commit { MessageBroadcastJob.set(wait: 1.seconds).perform_later self }
end
