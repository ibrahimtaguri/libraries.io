# frozen_string_literal: true

Rails.application.config.git_revision = if Rails.env.development?
    `git rev-parse HEAD`
  else
    ENV["REVISION_ID"].presence
  end
