require 'spec_helper'

feature 'Work In Progress help message', feature: true do
  let!(:project) { create(:project, visibility_level: Gitlab::VisibilityLevel::PUBLIC) }
  let!(:user)    { create(:user) }

  before do
    project.team << [user, :master]
    login_as(user)
  end

  context 'with WIP commits' do
    it 'shows a specific WIP hint' do
      visit new_namespace_project_merge_request_path(
        project.namespace,
        project,
        merge_request: {
          source_project_id: project.id,
          target_project_id: project.id,
          source_branch: 'wip',
          target_branch: 'master'
        }
      )

      within_wip_explanation do
        expect(page).to have_text(
          'It looks like you have some WIP commits in this branch'
        )
      end
    end
  end

  context 'without WIP commits' do
    it 'shows the regular WIP message' do
      visit new_namespace_project_merge_request_path(
        project.namespace,
        project,
        merge_request: {
          source_project_id: project.id,
          target_project_id: project.id,
          source_branch: 'fix',
          target_branch: 'master'
        }
      )

      within_wip_explanation do
        expect(page).not_to have_text(
          'It looks like you have some WIP commits in this branch'
        )
        expect(page).to have_text(
          "Start the title with WIP: to prevent a Work In Progress merge \
request from being merged before it's ready"
        )
      end
    end
  end

  def within_wip_explanation(&block)
    page.within '.js-no-wip-explanation' do
      yield
    end
  end
end
