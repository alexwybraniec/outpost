class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service
            .page(params[:page])
            .where(approved: nil)
            .includes(:organisation, :service_taxonomies, :taxonomies, :taggings, :meta, :contacts, :local_offer, :send_needs, :links, :cost_options, :regular_schedules, :suitabilities, locations: [:accessibilities])
            .with_last_approved_version
            .with_last_version
            .order(updated_at: :DESC)

          @requests = @requests.in_directory(params[:directory]) if params[:directory].present?

    end

    def update
        @request = Service.find(params[:id])
        if @request.approve
            redirect_to request.referer, notice: "Changes have been approved."
            # get directory data here and pass through to the email
            @request.organisation.users.kept.each do |user|
                ServiceMailer.with(service: @request, user: user).notify_owner_email.deliver_later
            end
        end
    end
end
