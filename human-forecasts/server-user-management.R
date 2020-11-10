
# read sheet with the user data
user_base <- googlesheets4::read_sheet(ss = identification_sheet, 
                                       sheet = "ids")

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
               removeModal()
             } else {
               showModal(modalDialog(
                 loginUI(id = "login"),
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
                                                        choices = c("yes", "no", "anonymous"), selected = "anonymous", inline = TRUE), 
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
                 if (input$password != input$password2) {
                   showNotification("Passwords don't match", type = "error")
                 } else {
                   showNotification("New user created", type = "message")
                   removeModal()
                   identification <- data.frame(forecaster = input$name, 
                                                username = input$username,
                                                password = sodium::password_store(input$password),
                                                email = input$email,
                                                expert = input$expert,
                                                appearboard = input$appearboard,
                                                affiliation = stringr::str_to_lower(input$affiliation),
                                                website = stringr::str_to_lower(input$affiliationsite),
                                                forecaster_id = round(runif(1) * 1000000))
                   
                   googlesheets4::sheet_append(data = identification, 
                                               ss = identification_sheet, 
                                               sheet = "ids")
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