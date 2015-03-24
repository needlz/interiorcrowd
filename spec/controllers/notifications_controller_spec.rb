require 'rails_helper'

RSpec.describe NotificationsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }
  let(:notification) { Fabricate(:designer_invite_notification, contest: contest, designer: designer) }

  describe 'show' do
    context 'not logged in' do
      before do
        get :show, id: notification.id
      end

      it 'returns 404' do
        get :show, id: notification.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged as not notification recipient' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'returns 404' do
        get :show, id: notification.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged as notification recipient' do
      before do
        sign_in(designer)
      end

      it 'sets a notification as read' do
        get :show, id: notification.id
        expect(notification.reload.read).to be_truthy
      end

      it 'redirects to corresponding page' do
        get :show, id: notification.id
        notification_view = DesignerNotifications::NotificationView.for_notification(notification)
        expect(response).to redirect_to(notification_view.href)
      end
    end
  end

end
