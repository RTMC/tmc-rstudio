test_that("Exercises are downloaded correctly", {
  token <- authenticate("rtest", "asdasdasd","https://tmc.mooc.fi")
  download_exercises(token = token,
                     exercise_id = "36463",
                     exercise_directory = "resources/downloaded_exercises/")
  expect_true(dir.exists("resources/downloaded_exercises/Week1"))
})
test_that("organizations are fetched from the server",{
  authenticate("rtest", "asdasdasd","https://tmc.mooc.fi")
  organizations<-getAllOrganizations()
  expect_true(length(organizations)>0)
  for(organization in organizations){
    expect_true(is.character(organization))
  }
})
test_that("courses associated with server and organization are fetched from the server",{
  authenticate("rtest", "asdasdasd","https://tmc.mooc.fi")
  courses<-getAllCourses("hy")
  expect_true(length(courses)>0)
  for(course in courses){
    expect_true(is.character(course))
  }
})
