class ProjectsController < ApplicationController
  def index
    @licenses = Project.popular_licenses.first(10)
    @created = Project.order('created_at DESC').limit(4)
    @platforms = Project.popular_platforms.first(10)
    @languages = Project.popular_languages.first(10)
    @contributors = GithubUser.top(30)
    @popular = Project.popular.first(4)
  end

  def show
    find_project
    @version = @project.versions.find_by!(number: params[:number]) if params[:number].present?
    @versions = @project.versions.to_a.sort
    if @version
      @dependencies = @version.dependencies
    elsif @versions.any?
      @dependencies = @versions.first.dependencies
    else
      @dependencies = []
    end
    if @project.github_repository
      @contributors = @project.github_repository.github_contributions.order('count DESC').includes(:github_user).limit(42)
      @related = @project.github_repository.projects.reject{ |p| p.id == @project.id }
    end
  end

  def find_project
    @project = Project.platform(params[:platform]).where('lower(name) = ?', params[:name].downcase).first
    raise ActiveRecord::RecordNotFound if @project.nil?
    redirect_to project_path(@project.to_param), :status => :moved_permanently if params[:platform] != params[:platform].downcase || params[:name] != @project.name
  end
end
