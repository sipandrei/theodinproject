require 'rails_helper'

RSpec.describe 'User Reset Progress', type: :system do
  include ButtonMatchers

  let!(:foundations_path) { create(:path, title: 'Foundations', default_path: true) }
  let!(:course) { create(:course, path: foundations_path) }
  let!(:section) { create(:section, course: course) }
  let!(:lesson) { create(:lesson, section: section) }
  let!(:rails_path) { create(:path, title: 'Rails') }
  let!(:user) { create(:user) }

  it 'resets path and lesson completion' do
    sign_in(user)
    visit paths_path
    click_on('My Path')

    within('.curriculum-title') do
      expect(page).to have_text('Foundations')
    end

    click_on('Open Course')
    find(:test_id, 'lesson_complete_btn').click

    expect(page).to have_no_submit_button('lesson_complete_btn')
    expect(user.lesson_completions.count).to eq(1)

    click_on('All Paths')
    find(:test_id, 'rails-select-path-btn').click
    click_on('My Path')

    within('.curriculum-title') do
      expect(page).to have_text('Rails')
    end

    # ERROR =>
    # visit edit_user_registration_path
  end
end
