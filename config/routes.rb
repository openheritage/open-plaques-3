Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  root 'home#index'

  devise_for :users

  scope '/plaques' do
    resource :latest, as: :latest, controller: :plaques_latest, only: :show
  end

  resources :plaques do
    member do
      post 'flickr_search'
      get 'flickr_search_all'
    end
    resource :location, controller: :plaque_location, only: :edit
    resource :series, controller: :plaque_series, only: :edit
    resource :colour, controller: :plaque_colour, only: :edit
    resource :geolocation, controller: :plaque_geolocation, only: :edit
    resource :inscription, controller: :plaque_inscription, only: :edit
    resource :description, controller: :plaque_description, only: [:edit, :show]
    resource :language, controller: :plaque_language, only: :edit
    resources :connections, controller: :personal_connections, as: :connections
    resource :photos, controller: :plaque_photos, only: :show
    resource :talk, controller: :plaque_talk, only: :create
    resources :sponsorships
  end
  # map tiles are numbered using the convention at http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
  match 'plaques/tiles/:zoom/:x/:y' => 'plaques#index', constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
  match 'plaques/:filter/tiles/:zoom/:x/:y' => 'plaques#index', id: :filter, constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]

  resources :colours, only: [:new, :create]
  resources :languages, only: [:new, :create]
  resources :organisations do
    collection do
      get 'autocomplete'
    end
    member do
      post 'geolocate'
    end
    resource :plaques, controller: :organisation_plaques, only: :show
    match 'plaques/tiles/:zoom/:x/:y' => 'organisation_plaques#show', constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
    match 'plaques/:filter/tiles/:zoom/:x/:y' => 'organisation_plaques#show', id: :filter, constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
    match 'plaques/:filter' => 'organisation_plaques#show', via: [:get]
    resource :subjects, controller: :organisation_subjects, only: :show
  end
  resources :personal_roles
  resources :picks
  resources :places, controller: :countries, as: :countries do
    collection do
      get 'autocomplete', controller: :areas
    end
    resources :areas do
      member do
        post 'geolocate'
      end
      resource :plaques, controller: :area_plaques, only: :show
      resource :subjects, controller: :area_subjects, only: :show
      match 'plaques/tiles/:zoom/:x/:y' => 'area_plaques#show', constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
      match 'plaques/:filter/tiles/:zoom/:x/:y' => 'area_plaques#show', id: :filter, constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
      match 'plaques/:filter' => 'area_plaques#show', via: [:get]
    end
    resource :plaques, controller: :country_plaques, only: :show
    resource :subjects, controller: :country_subjects, only: :show
    match 'plaques/:filter' => 'country_plaques#show', via: [:get]
  end
  resources :photos, only: [:create, :edit, :new, :show, :update]
  resources :photographers, as: :photographers, only: [:create, :index, :show, :new]

  scope '/roles' do
    resources 'a-z', controller: :roles_by_index, as: 'roles_by_index', only: [:show, :index]
    resources 'precedence', controller: :roles_by_precedence, as: 'roles_by_precedence', only: [:index]
  end
  resources :roles do
    collection do
      get 'autocomplete'
    end
  end

  scope '/people' do
    resources 'a-z', controller: :people_by_index, as: 'people_by_index', only: :show
  end
  scope '/subjects' do
    resources 'a-z', controller: :people_by_index, as: 'people_by_index', only: :show
  end
  scope '/women' do
    resources 'a-z', controller: :women_by_index, as: 'women_by_index', only: :show
  end
  resources :people do
    collection do
      get 'autocomplete'
    end
    resource :plaques, controller: :person_plaques, only: :show
    resource :roles, controller: :person_roles, only: :show
  end

  resources :series do
    member do
      post 'geolocate'
    end
    resource :plaques, controller: :series_plaques, only: :show
    match 'plaques/tiles/:zoom/:x/:y' => 'series_plaques#show', constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
    match 'plaques/:filter/tiles/:zoom/:x/:y' => 'series_plaques#show', id: :filter, constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
    match 'plaques/tiles/:zoom/:x/:y' => 'series_plaques#show', constraints: { zoom: /\d{2}/, x: /\d+/, y: /\d+/ }, via: [:get]
  end
  get 'series/:id/:series_ref', to: 'series#show'
  resources :todo
  resources :verbs, only: [:create, :index, :show, :new] do
    collection do
      get 'autocomplete'
    end
  end

  match 'search' => 'search#index', via: [:get]
  match 'search/:phrase' => 'search#index', via: [:get]
  match 'match' => 'match#index', via: [:get]
  resources :pages
  get 'about', controller: :static_pages
  get 'contribute', controller: :static_pages
  get 'contact', controller: :static_pages
  get 'data', controller: :static_pages
end
