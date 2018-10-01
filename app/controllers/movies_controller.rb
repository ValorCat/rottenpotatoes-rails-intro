class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    selected_sort = params[:sort]
    selected_sort ||= session[:sort]
    
    case selected_sort
      when 'title'
        @movies = Movie.order(:title)
        @title_header = 'hilite'
      when 'release_date'
        @movies = Movie.order(:release_date)
        @release_date_header = 'hilite'
      else
        @movies = Movie.all
    end
    
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings]
    @selected_ratings ||= session[:ratings]
    @selected_ratings ||= @all_ratings.map do |k, v| k end
    
    if @selected_ratings.respond_to? :keys
      @selected_ratings = @selected_ratings.keys
    end
    
    mustUpdateSort = session[:sort] != params[:sort]
    mustUpdateFilter = session[:ratings] != params[:ratings]
    
    # puts "!!! Selected sort:     #{selected_sort}"
    # puts "!!!    Params sort:    #{params[:sort]}"
    # puts "!!!    Session sort:   #{session[:sort]}"
    # puts "!!! Selected filter:   #{@selected_ratings}"
    # puts "!!!    Params filter:  #{params[:ratings]}"
    # puts "!!!    Session filter: #{session[:ratings]}"
    
    if mustUpdateSort or mustUpdateFilter
      session[:sort] = selected_sort if mustUpdateSort
      session[:ratings] = @selected_ratings if mustUpdateFilter
      flash.keep
      redirect_to sort: selected_sort, ratings: @selected_ratings
      return
    end
    
    @movies = @movies.where(rating: @selected_ratings)
    
    # @all_ratings = Movie.all_ratings
    
    # if params[:ratings]
    #   @selected_ratings = params[:ratings].keys
    #   if session[:sort_choice]
    #     session.delete(:sort_choice)
    #     redirect_to movies_path(ratings: params[:ratings], sort: session[:sort_choice])
    #     return
    #   end
    # elsif session[:rating_choice]
    #   @selected_ratings = session[:rating_choice]
    # else
    #   @selected_ratings = {}
    # end
    
    # if params[:sort]
    #   @selected_sort = params[:sort]
    #   if session[:rating_choice]
    #     #session.delete(:rating_choice)
    #     redirect_to movies_path(ratings: session[:rating_choice], sort: params[:sort])
    #     return
    #   end
    # elsif session[:sort_choice]
    #   @selected_sort = session[:sort_choice]
    # end
    
    # case @selected_sort
    #   when 'title'
    #     @movies = Movie.order(:title)
    #     @title_header = 'hilite'
    #   when 'release_date'
    #     @movies = Movie.order(:release_date)
    #     @release_date_header = 'hilite'
    #   else
    #     @movies = Movie.all
    # end
    # @movies = @movies.where(rating: @selected_ratings)
    
    # session[:rating_choice] = @selected_ratings
    # session[:sort_choice] = @selected_sort
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
