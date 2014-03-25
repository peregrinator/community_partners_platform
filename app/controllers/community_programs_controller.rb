class CommunityProgramsController < ApplicationController
  def index
    @community_programs = CommunityProgram.accessible_by(current_ability).includes(:organization).order("organizations.name")
    authorize! :index, @community_programs
  end

  def show
    @community_program = CommunityProgram.find(params[:id])
    authorize! :show, @community_program
  end

  def new
    @community_program = CommunityProgram.new(community_program_params)
    authorize! :new, @community_program

    @community_program.build_primary_quality_element
    @community_program.build_secondary_quality_element
  end

  def create
    @community_program = CommunityProgram.new(community_program_params)
    authorize! :create, @community_program

    @community_program.save!

    redirect_to community_partner_path(@community_program)
  rescue ActiveRecord::RecordInvalid
    @community_program.build_primary_quality_element unless @community_program.primary_quality_element
    @community_program.build_secondary_quality_element unless @community_program.secondary_quality_element

    render :new
  end

  def edit
    @community_program = CommunityProgram.find(params[:id])
    authorize! :edit, @community_program

    @community_program.build_secondary_quality_element unless @community_program.secondary_quality_element.present?
  end

  def update
    @community_program = CommunityProgram.find(params[:id])
    authorize! :update, @community_program

    @community_program.update_attributes!(community_program_params)

    redirect_to community_partner_path(@community_program)
  rescue ActiveRecord::RecordInvalid
    @community_program.build_primary_quality_element unless @community_program.primary_quality_element
    @community_program.build_secondary_quality_element unless @community_program.secondary_quality_element

    render :edit
  end

  private

  def community_program_params
    params.require(:community_program).permit(:mou_on_file,
                                              :name,
                                              :notes,
                                              :organization_id,
                                              :school_id,
                                              :school_user_id,
                                              :secondary_quality_element_id,
                                              :service_description,
                                              :service_time_of_day,
                                              :site_agreement_on_file,
                                              :student_population_id,
                                              :target_population,
                                              :user_id,
                                              day_ids: [],
                                              demographic_group_ids: [],
                                              ethnicity_culture_group_ids: [],
                                              grade_level_ids: [],
                                              primary_quality_element_attributes: [
                                                :id,
                                                :quality_element_id,
                                                service_type_ids: []
                                              ],
                                              secondary_quality_element_attributes: [
                                                :id,
                                                :quality_element_id,
                                                service_type_ids: []
                                              ],
                                              service_time_ids: []
                                             )
  end
end