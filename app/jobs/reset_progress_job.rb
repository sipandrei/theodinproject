class ResetProgressJob
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(user_id)
    user = User.find_by(id: user_id)
    default_path = Path.default_path
    user.lesson_completions.destroy_all
    user.update(path: default_path) unless user.path.default_path
  end
end
