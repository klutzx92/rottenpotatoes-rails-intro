class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect = false
    @all_ratings = Movie.all_ratings
    @ratings_to_show = []
    
    from_within = params[:commit] == 'Refresh' ? true : false
    checked = false
    
    #checkboxes
    if params[:ratings]
      @ratings_to_show = params[:ratings].keys
      checked = true
      session[:ratings] = params[:ratings]
    else
      if session[:ratings] 
        @ratings_to_show = session[:ratings].keys
        checked = true
      else
        @ratings_to_show = []
      end
    end
    
    #header clicks
    if params[:click]
      @click = params[:click]
      session[:click] = @click
    else
      if session[:click]
        @click = session[:click]
        redirect = true
      end
    end
      
    if @click == 'Movie Title'
      sort_by = :title
    elsif @click == 'Release Date'
      sort_by = :release_date
    end
    
    if from_within and params[:ratings] == nil
      session.delete(:ratings)
    end
    
    if redirect
      redirect_to movies_path({:rating => session[:rating], :click => session[:click]})
    else
      if checked
        @movies = Movie.with_ratings(@ratings_to_show).order(sort_by)
      else
        @movies = Movie.all.order(sort_by)
      end
    end
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
