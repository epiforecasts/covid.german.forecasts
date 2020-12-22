
# read sheet with the user data
user_base <- googlesheets4::read_sheet(ss = identification_sheet, 
                                       sheet = "ids")

animal_list <- readr::read_csv("animals.csv")$Animal

identification <- reactiveVal()


# login module
credentials <- callModule(shinyauthr::login, 
                          id = "login", 
                          data = user_base,
                          user_col = username,
                          pwd_col = Password,
                          log_out = reactive(logout_init()), 
                          sodium_hashed = TRUE)

# logout module - not sure this is needed at all
logout_init <- callModule(shinyauthr::logout, 
                          id = "logout", 
                          active = reactive(TRUE))





# If user has entered their information succesfully, all modals are closed
observeEvent(credentials()$user_auth, 
             if (credentials()$user_auth) {
               
               # assign user info to the identification data.frame
               identification(credentials()$info)
               removeModal()
               
               # if (Sys.Date() > app_end_date) {
               #   showModal(modalDialog(
               #     "The app does not currently allow new predictions. Wait until next Saturday, 16.00 CET to make submit new forecasts. You can, however, take a tour and play around with the app."
               #   )) 
               # }
               
             } else {
               
               if (is_updated) {
                 data_update_message <- ""
               } else {
                 data_update_message <- "Data will be updated every Saturday (around 16.00 UTC). You can make forecasts regardless, but you will not have the last week of data."
               }
                
               
               showModal(modalDialog(
                 loginUI(id = "login"),
                 br(), 
                 fluidRow(column(12, 
                                 style = 'padding-left: 15px; padding-right: 15px',
                                 h4("Note: If the app doesn't fit on your screen we highly recommend you zoom out a bit"), 
                                 h5("If you just want to take a look, log in with username and password 'test'"))),
                 fluidRow(column(12, 
                                 style = 'padding-left: 15px; padding-right: 15px',
                                 h4(data_update_message))),
                 br(),
                 actionButton(inputId = "new_user", 
                              label = "Create New User"),
                 footer = NULL
               ))}, 
             ignoreNULL = FALSE)


# if user intends to create a new account in the login modal
# uesr is shown the Terms and Instructions they need to consent to
observeEvent(input$new_user, 
             {
               removeModal()
               showModal(modalDialog(
                 size = "l",
                 title = "Terms and Instructions", 
                 HTML(instructions),
                 br(),
                 br(),
                 
                 fluidRow(column(3, actionButton(inputId = "consent", 
                                                 label = "I understand and consent")), 
                          column(3, actionButton(inputId = "backtologin", 
                                                 label = "Back to login"))),
                 footer = NULL,
               ))
             })


# once user has consented to terms and instructions, a new dialog is openend
# where the user data needs to be entered
# open dialog to create new user
observeEvent(input$consent, 
             {
               removeModal()
               showModal(modalDialog(
                 size = "l",
                 title = "Create New User", 
                 fluidRow(column(12, h3("Your Name"))),
                 fluidRow(column(12, textInput("name", label = NULL))),
                 fluidRow(column(12, "Please enter your name. (If you really do not wish to be identified, you can also enter an imaginary name or leave it blank.)")),
                 # br(),
                 fluidRow(column(12, h3("User Name and Performance Board"))),
                 fluidRow(column(6, textInput("username", label = "Your username")), 
                          column(6, tipify(radioButtons(inputId = "appearboard", label = "Appear on Performance Board?", 
                                                        choices = c("yes", "anonymous"), selected = "anonymous", inline = TRUE), 
                                           title = "Do you want to appear on the Performance Board at all?"))), 
                 fluidRow(column(12, "Please provide a username needed to log in. If you select the appropriate option, this username will also appear on our performance board. If you select 'anonymous', an anonymous alias will appear instead")),
                 # br(), 
                 fluidRow(column(12, h3("Password"))),
                 fluidRow(column(6, passwordInput("password", "Choose a password")), 
                          column(6, passwordInput("password2", "Repeat password"))),
                 # br(),
                 fluidRow(column(12, h3("Email"))),
                 fluidRow(column(12, "Please submit your email, if you like. If you provide your email, we will send you weekly reminders to conduct the survey and may contact you in case of questions.")), 
                 fluidRow(column(12, textInput("email", label = "Email"))),
                 fluidRow(column(12, h3("Domain Expertise"))),
                 fluidRow(column(4, 
                                 checkboxInput(inputId = "expert", 
                                               label = "Do you have domain expertise?")), 
                          column(4, textInput(inputId = "affiliation", label = "Affiliation")),
                          column(4, textInput(inputId = "affiliationsite", "Institution website"))),
                 fluidRow(column(12, "If you work in infectious disease modelling or have professional experience in any related field, please tick the appropriate box and state the website of the institution you are or were associated with")),
                 br(),
                 fluidRow(column(3, actionButton(inputId = "createnew2", 
                                                 label = HTML("<b>Create New User</b>"))), 
                          column(3, actionButton(inputId = "backtologin", 
                                                 label = "Back to login"))),
                 footer = NULL
               ))
               
             })


# if new user is created, close all modals so that the user can 
# proceed with the app
observeEvent(input$createnew2,
             {
               if ((input$username != "") && (input$password != "")) {
                 existing_users <- unique(user_base$username)
                 
                 if (input$username %in% existing_users) {
                   showNotification("Username already taken", type = "error")
                 } else if (input$password != input$password2) {
                   showNotification("Passwords don't match", type = "error")
                 } else {
                   showNotification("New user created", type = "message")
                   removeModal()
                   
                   generate_random_id <- function() {
                     existing_ids <- unique(user_base$forecast_id)
                     id <- round(runif(1) * 1000000)
                     while (id %in% existing_ids) {
                       id <- round(runif(1) * 1000000)
                     }
                     return(id)
                   }
                   
                   create_leaderboard_name <- function() {
                     if (input$appearboard == "yes") {
                       board_name <- input$username
                     } else {
                       existing_names <- unique(user_base$board_name)
                       
                       used_animals <- gsub(".*_","", existing_names)
                       free_animals <- setdiff(animal_list, used_animals)
                       
                       if (length(free_animals) > 0) {
                         n <- length(free_animals)
                         index <- sample(x = 1:n, size = 1)
                         board_name = paste0("anonymous_", free_animals[index])
                       } else {
                         # make this more flexible in the future
                         animal_list <- paste0(animal_list, "_2")
                         free_animals <- setdiff(animal_list, used_animals)
                         n <- length(free_animals)
                         index <- sample(x = 1:n, size = 1)
                         board_name = paste0("anonymous_", free_animals[index])
                       }
                     }
                     return(board_name) 
                   }
                   
                   identification <- data.frame(forecaster = input$name, 
                                                username = input$username,
                                                password = sodium::password_store(input$password),
                                                email = input$email,
                                                expert = input$expert,
                                                appearboard = input$appearboard,
                                                affiliation = stringr::str_to_lower(input$affiliation),
                                                website = stringr::str_to_lower(input$affiliationsite),
                                                forecaster_id = generate_random_id(), 
                                                board_name = create_leaderboard_name())
                   
                   # assign data.frame with identification values to the 
                   # reactive identification sheet
                   identification(identification) 
                   
                   googlesheets4::sheet_append(data = identification, 
                                               ss = identification_sheet, 
                                               sheet = "ids")
                   
                   if (Sys.Date() > app_end_date) {
                     showModal(modalDialog(
                       "The app does not currently allow new predictions. Wait until next Saturday, 16.00 CET to make submit new forecasts. You can, however, take a tour and play around with the app."
                     )) 
                   }
                   
                 }
               } else {
                 showNotification("Username or password missing", type = "error")
               }
             })


# whenever user wants to navigate back to login
observeEvent(input$backtologin,
             {
               print("triggered")
               # session$reload()
               removeModal()
               showModal(modalDialog(
                 loginUI(id = "login"),
                 br(), 
                 actionButton(inputId = "new_user", 
                              label = "Create new user"),
                 footer = NULL
               ))
             })




# code to update user. Currently not in use
# 
# observeEvent(c(input$update_user, input$update_user_q), 
#              {
#                showModal(modalDialog(
#                  
#                  size = "l",
#                  title = "Update User Information", 
#                  fluidRow(column(12, h3("Your Name"))),
#                  fluidRow(column(12, textInput("name", label = NULL, value = identification()$name))),
#                  fluidRow(column(12, "Please enter your name. (If you really do not wish to be identified, you can also enter an imaginary name or leave it blank.)")),
#                  # br(),
#                  fluidRow(column(12, h3("User Name and Performance Board"))),
#                  fluidRow(column(6, textInput("username", label = "Your username", value = identification()$username)), 
#                           column(6, tipify(radioButtons(inputId = "appearboard", label = "Appear on Performance Board?", 
#                                                         choices = c("yes", "anonymous"), selected = "anonymous", inline = TRUE), 
#                                            title = "Do you want to appear on the Performance Board at all?"))), 
#                  fluidRow(column(12, "Please provide a username needed to log in. If you select the appropriate option, this username will also appear on our performance board. If you select 'anonymous', an anonymous alias will appear instead")),
#                  # br(), 
#                  fluidRow(column(12, h3("Password"))),
#                  fluidRow(column(6, passwordInput("password", "Choose a password")), 
#                           column(6, passwordInput("password2", "Repeat password"))),
#                  # br(),
#                  fluidRow(column(12, h3("Email"))),
#                  fluidRow(column(12, "Please submit your email, if you like. If you provide your email, we will send you weekly reminders to conduct the survey and may contact you in case of questions.")), 
#                  fluidRow(column(12, textInput("email", label = "Email", value = identification()$email))),
#                  fluidRow(column(12, h3("Domain Expertise"))),
#                  fluidRow(column(4, 
#                                  checkboxInput(inputId = "expert", 
#                                                label = "Do you have domain expertise?")), 
#                           column(4, textInput(inputId = "affiliation", label = "Affiliation", value = identification()$affiliation)),
#                           column(4, textInput(inputId = "affiliationsite", "Institution website", value = identification()$website))),
#                  fluidRow(column(12, "If you work in infectious disease modelling or have professional experience in any related field, please tick the appropriate box and state the website of the institution you are or were associated with")),
#                  br(),
#                  fluidRow(column(3, actionButton(inputId = "confirm_update_user", 
#                                                  label = HTML("<b>Update user information</b>"))), 
#                           column(3, actionButton(inputId = "cancel", 
#                                                  label = "Cancel"))),
#                  footer = NULL
#                ))
#              }, 
#              ignoreInit = TRUE)
# 
# observeEvent(input$cancel, 
#              removeModal())
# 
# observeEvent(input$confirm_update_user, 
#              {
#                
#              })
