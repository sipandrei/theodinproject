require 'rails_helper'

RSpec.describe 'User Reset Progress', type: :system do
  let!(:foundations_path) { create(:path, title: 'Foundations', default_path: true) }
  let!(:foundation_course) { create(:course, title: 'Foundations', path: foundations_path) }
  let!(:foundation_section) { create(:section, course: foundation_course) }
  let!(:foundation_first_lesson) { create(:lesson, title: 'First Foundation Lesson', section: foundation_section) }
  let!(:foundation_second_lesson) { create(:lesson, section: foundation_section) }
  let!(:rails_path) { create(:path, title: 'Rails') }
  let!(:rails_course) { create(:course, title: 'Rails', path: rails_path) }
  let!(:rails_section) { create(:section, course: rails_course) }
  let!(:rails_first_lesson) { create(:lesson, title: 'First Rails Lesson', section: rails_section) }
  let!(:rails_second_lesson) { create(:lesson, section: rails_section) }
  let!(:user) { create(:user) }

  it 'resets path and lesson completion - ACCESS PAGE DIRECTLY' do
    sign_in(user)
    visit dashboard_path

    within(find('.skills')) do
      expect(page).to have_content(foundation_course.title)
      expect(find(:test_id, 'default-badge')).to have_text('')
      expect(find(:test_id, 'foundations-start-btn')).to have_text('Start')
    end

    visit path_course_lesson_path(foundations_path, foundation_course, foundation_first_lesson)
    within(find('.lesson-button-group')) do
      find(:test_id, 'complete_btn').click #=> intermittent fail (resolved?)
    end
    visit dashboard_path

    expect(user.lesson_completions.count).to eq(1)
    within(find('.skills')) do
      expect(page).to have_content(foundation_course.title)
      expect(find(:test_id, 'progress-badge')).to have_text('50%') #=> intermittent fail (not resolved)
      expect(find(:test_id, 'foundations-resume-btn')).to have_text('Resume')
    end

    visit paths_path
    find(:test_id, 'rails-select-path-btn').click
    visit path_course_lesson_path(rails_path, rails_course, rails_first_lesson)

    within(find('.lesson-button-group')) do #=> intermittent fail (not resolved)
      find(:test_id, 'complete_btn').click
    end
    visit dashboard_path

    expect(user.lesson_completions.count).to eq(2)
    within(find('.skills')) do
      expect(page).to have_content(rails_course.title) #=> intermittent fail (not resolved)
      expect(find(:test_id, 'progress-badge')).to have_text('50%') #=> intermittent fail (resolved?)
      expect(find(:test_id, 'rails-resume-btn')).to have_text('Resume')
    end

    visit edit_user_registration_path
    page.accept_confirm do
      find(:test_id, 'user-reset-progress-link').click
    end
    visit dashboard_path

    expect(user.lesson_completions.count).to eq(0)
    within(find('.skills')) do
      expect(page).to have_content(foundation_course.title)
      expect(find(:test_id, 'default-badge')).to have_text('')
      expect(find(:test_id, 'foundations-start-btn')).to have_text('Start')
    end
  end

  it 'resets path and lesson completion - TESTS NAVIGATE PAGES' do
    sign_in(user)
    visit dashboard_path

    expect(page).to have_content(foundation_course.title)
    expect(find(:test_id, 'default-badge')).to have_text('')
    expect(find(:test_id, 'foundations-start-btn')).to have_text('Start')

    find(:test_id, 'foundations-start-btn').click
    click_on('First Foundation Lesson')
    find(:test_id, 'complete_btn').click
    find('.odin-dropdown').click
    click_on('Dashboard')

    expect(user.lesson_completions.count).to eq(1)
    expect(page).to have_content(foundation_course.title)
    expect(find(:test_id, 'progress-badge')).to have_text('50%')
    expect(find(:test_id, 'foundations-resume-btn')).to have_text('Resume')

    click_on('All Paths')
    find(:test_id, 'rails-select-path-btn').click
    click_on('Open Course')
    click_on('First Rails Lesson')
    find(:test_id, 'complete_btn').click
    find('.odin-dropdown').click
    click_on('Dashboard')

    expect(user.lesson_completions.count).to eq(2)
    expect(page).to have_content(rails_course.title)
    expect(find(:test_id, 'progress-badge')).to have_text('50%')
    expect(find(:test_id, 'rails-resume-btn')).to have_text('Resume')

    find('.odin-dropdown').click
    click_on('Settings')
    page.accept_confirm do
      find(:test_id, 'user-reset-progress-link').click
    end
    find('.odin-dropdown').click
    click_on('Dashboard')

    expect(user.lesson_completions.count).to eq(0)
    expect(page).to have_content(foundation_course.title)
    expect(find(:test_id, 'default-badge')).to have_text('')
    expect(find(:test_id, 'foundations-start-btn')).to have_text('Start')
  end
end
