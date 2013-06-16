class ApiController < ApplicationController
  def community_partners
    @community_partners = CommunityPartner.includes(:school, :organization).all

    render :json => @community_partners, :root => "community_partners"
  end

  def school_hierarchy
    @schools = School.includes(:community_partners, :organizations).all
    
    json = {
            name: 'Schools',
            size: 100,
            child_count: 2,
            children: @schools.map do |object|
              {
                name: object.try(:name),
                size: 500,
                child_count: object.organizations.count,
                children: object.organizations.uniq.map do |org|
                  {
                    name: org.try(:name),
                    child_count: org.school_quality_indicator_sub_areas.uniq.size,
                    size: 800,
                    children: org.school_quality_indicator_sub_areas.uniq.map{ |sq| {name: sq.try(:name), size: 900} }
                  }
                end
              }
            end
          }
    render :json => json #@schools, :serializer => SchoolHierarchySerializer, :root => :school
  end
end
