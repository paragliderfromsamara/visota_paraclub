VisotaParaclubRu::Application.routes.draw do

  resources :voices, :only => [:create, :destroy]	
  resources :votes
  resources :events


  #admin_tools
	get "admin_tools/deleted_albums"   #удалённые альбомы
	get "admin_tools/deleted_themes"   #удалённые темы
	get "admin_tools/deleted_messages" #удалённые сообщения или комментарии
	get "admin_tools/deleted_articles" #удалённые статьи
	get "admin_tools/deleted_photos"   #удалённые статьи
	get "admin_tools/hidden_albums"    #скрытые альбомы
	get "admin_tools/hidden_themes"	   #скрытые альбомы
	get "admin_tools/hidden_messages"  #скрытые сообщения
	get "admin_tools/hidden_articles"  #скрытые статьи
	get "admin_tools/hidden_photos"    #скрытые фотографии
	get "admin_tools/deleted_entities" #удалённые объекты
    get "admin_tools/hidden_entities"  #скрытые объекты	
	get "admin_tools/site_images" #изображения для сайта	
	get "admin_tools/entities_recovery"	#Восстановление удалённых объектов
	get "admin_tools/disabled_events" #Скрытые новости
	get "admin_tools/adaptation_to_new"     #Создать темы
  #admin_tools_end
  
  #articles
  resources :articles
  get "articles/bind_videos_and_albums"
  post "articles/upload_photos"
  match '/articles/:id/upload_photos', :to => 'articles#upload_photos'
  match '/articles/:id/bind_videos_and_albums', :to => 'articles#bind_videos_and_albums'
  #articles_end

  #old_messages_controller
  resources :old_messages, :only => [:index, :edit, :update, :destroy]
  get "old_messages/get_old_messages"
  get "old_messages/old_msg_users"
  get "old_messages/assign_users_to_old_msgs"
  post "old_messages/assign_users_to_old_msgs"
  #old_messages_controller end
  
  #messages_controller
  resources :messages
  get "messages/replace_message"
  get "messages/do_replace_message"
  post "messages/upload_photos"
  match '/messages/:id/replace_message', :to => 'messages#replace_message'
  match '/messages/:id/upload_photos', :to => 'messages#upload_photos' #загрузка с помощью dropzone.js и собственную функцию photosUploader() в application.js
  match '/do_replace_message', :to => 'messages#do_replace_message'
  #messages_controller end
  
  #themes_controller  
  resources :themes
  get "themes/merge_themes"
  get "themes/get_themes_list"
  post "themes/do_merge_themes"
  post "themes/theme_switcher"
  post "themes/add_photos"
  post "themes/add_files"
  post "themes/upload_photos"
  match '/themes/:id/theme_switcher', :to => 'themes#theme_switcher'
  match '/get_themes_list', :to => 'themes#get_themes_list'
  match '/themes/:id/merge_themes', :to => 'themes#merge_themes'
  match '/themes/:id/new_message', :to => 'themes#new_message' #Новое сообщение в теме
  match '/themes/:id/add_photos', :to => 'themes#add_photos' #Загрузка фото
  match '/themes/:id/add_files', :to => 'themes#add_files' #Загрузка файлов
  match '/do_merge_themes', :to => 'themes#do_merge_themes'
  match '/themes/:id/upload_photos', :to => 'themes#upload_photos' #загрузка с помощью dropzone.js и собственную функцию photosUploader() в application.js
  #themes_controller end

  #topics controller
  resources :topics
  match '/visota_life', :to => 'topics#index'
  match '/gost.htm', :to => 'topics#index'
  #topics controller end

  #videos_controller
  resources :videos
  get "videos/new_comment"
  match '/videos/:id/new_comment', :to => 'videos#new_comment'
  #videos_controller end

  #photos_controller
  resources :photos
  get "photos/edit_photos"
  get "photos/recovery"
  post "photos/edit_photos"
  post "photos/update_photos"
  match '/photos/:id/recovery', :to => 'photos#recovery' #восстановление
  match '/edit_photos', :to => 'photos#edit_photos'
  match '/update_photos', :to => 'photos#update_photos'
  #photos_controller end

  #photo_albums_controller
  resources :photo_albums
  get "photo_albums/unbinded_to_article_albums"
  post "photo_albums/upload_photos"
  get "photo_albums/get_albums_list"
  match '/get_albums_list', :to => 'photo_albums#get_albums_list'
  match '/unbinded_to_article_albums', :to => 'photo_albums#unbinded_to_article_albums'#Ссылка на вывод списка альбомов не прикрепленных к статье...
  match '/photo_albums/:id/upload_photos', :to => 'photo_albums#upload_photos' #загрузка с помощью dropzone.js и собственную функцию photosUploader() в application.js
  #photo_albums_controller end


  resources :steps
  
  #users_controller
  resources :users
  get "users/password_mail_sent"
  get "users/make_mail"
  get "users/remember_password"
  get "users/mail_switcher"
  get "users/thanks"
  put "users/update_mailer"
  get "users/user_check"
  get "users/mail_test"
  get "users/check_email_and_name"
  get "users/videos"
  get "users/photo_albums"
  get "users/steps"
  match '/password_mail_sent', :to => 'users#password_mail_sent'
  match '/make_mail', :to => 'users#make_mail'
  match '/remember_password', :to => 'users#remember_password'
  match '/thanks', :to => 'users#thanks'
  match '/mail_switcher', :to => 'users#mail_switcher'
  match '/user_check', :to => 'users#user_check'
  match "/pilots", :to => 'users#index'
  match "/welcome", :to => 'users#welcome'
  match "/update_mailer", :to => 'users#update_mailer'
  match "/check_email_and_name", :to => 'users#check_email_and_name' #проверка имени и почтового адреса на занятость.
  match "/users/:id/videos", :to => "users#videos"
  match "/users/:id/steps", :to => "users#steps"
  match '/users/:id/photo_albums', :to => 'users#photo_albums'
  #users_controller
  
  #sessions_controller
  resources :sessions, :only => [:new, :create, :destroy]
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  match '/create_session',  :to => 'sessions#create'
  match '/signup',  :to => 'users#new'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  #sessions_controller end
  
  #pages_controller
  get "pages/index"
  get "pages/school"
  get "pages/contacts"
  get "pages/about_us"
  get "pages/feed"
  get "pages/search"
  match '/index', :to => 'pages#index'
  match '/school', :to => 'pages#school'
  match '/about_us', :to => 'pages#about_us'
  match '/contacts', :to => 'pages#contacts'
  match '/styles', :to => 'pages#styles'
  match '/feed', :to => 'pages#feed'
  match '/search', :to => 'pages#search'
  #pages_controller end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
