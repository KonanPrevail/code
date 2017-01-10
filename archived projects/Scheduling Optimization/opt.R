# cleaning
rm(list=ls())

options(error=NULL)

# some initialization
path="C:/Users/mcd04005/Documents/Modeling/Optimization/"
setwd(path)

#reading data
exam_data <- read.csv(paste(path, "uc_exam.csv",sep=""),sep=",", header=T)
cross_exam_data <- read.csv(paste(path, "uc_cross_exam.csv",sep=""),sep=",", header=T)
student_data <- read.csv(paste(path, "uc_student.csv",sep=""),sep=",", header=T)
student_exam_data <- read.csv(paste(path, "uc_student_exam.csv",sep=""),sep=",", header=T)
instructor_data <- read.csv(paste(path, "uc_instructor.csv",sep=""),sep=",", header=T)
instructor_exam_data <- read.csv(paste(path, "uc_instructor_exam.csv",sep=""),sep=",", header=T)
exam_room_data <- read.csv(paste(path, "uc_exam_room.csv",sep=""),sep=",", header=T)
period_data <- read.csv(paste(path, "uc_dtm.csv",sep=""),sep=",", header=T)
room_data <- read.csv(paste(path, "uc_room.csv",sep=""),sep=",", header=T)
meet_time_data <- read.csv(paste(path, "uc_meet_time.csv",sep=""),sep=",", header=T)

ratio <- 0.1
room_data[,2] <- ceiling(room_data[,2]*(1+ratio))

# variable naming
names(exam_data) <- c("exam_id","tot","type","course_id","common_block")
names(cross_exam_data) <- c("exam_id","exam_id_cmbnd")
names(student_data) <- c("student_id")
names(student_exam_data) <- c("student_id","exam_id")
names(instructor_data) <- c("instructor_id")
names(instructor_exam_data) <- c("instructor_id","exam_id")
names(period_data) <- c("exam_day","exam_time","period_id")
names(room_data) <- c("room_id","cap")

# set id and matrix
n_exam <- dim(exam_data)[1]
n_student <- dim(student_data)[1]
n_student_exam <- dim(student_exam_data)[1]
n_instructor <- dim(instructor_data)[1]
n_instructor_exam <- dim(instructor_exam_data)[1]
n_period <- dim(period_data)[1]
n_day <- max(period_data[,1])
n_time <- max(period_data[,2])
n_room <- dim(room_data)[1]
n_dayperiod <-5 # number of period a day

# data who takes which exams
student_exam_mat <- matrix(0, nrow=n_student, ncol=n_exam)
for (i in 1:n_student_exam) {
  # which function returns the indexes of the elements. Should differentiate the indexes and the ids 
  student_exam_mat[which(student_data==student_exam_data[i,1]),which(exam_data[,1]==student_exam_data[i,2])]=1
}

# data of faculty members who protor which exams
instructor_exam_mat <- matrix(0, nrow=n_instructor, ncol=n_exam)
for (i in 1:n_instructor_exam) {
  # which function returns the indexes of the elements. Should differentiate the indexes and the ids 
  instructor_exam_mat[which(instructor_data==instructor_exam_data[i,1]),which(exam_data[,1]==instructor_exam_data[i,2])]=1
}

# Need period to day conversion
period_day_mat <- matrix(0, nrow=n_period, ncol=n_day) 
for (i in 1:n_period) {
  day <- period_data[i,1] # get day given period
  period_day_mat[i,day] <- 1   
}

# initialize assignments for exams to periods, one exam to 1 period
# evening classes have evening exams on the same days, and others have exams on the same days of the class meeting, so the initial cost 
# for evening class assigned to some other periods, and classes assigned exams on different days = 0, so don't need to add this to the soft constraint function
evening_period <- matrix(c(5,10,15,20,25,30))
exam_period_mat <- matrix(0, nrow=n_exam, ncol=n_period)
for(i in 1:n_exam) {
  # get the meeting periods, converted from meeting day pattern
  meet_array <- meet_time_data[which(meet_time_data[,1]==i),3:8] # the same class (same course id, same class number) may be split to meet in different days, each class takes 1 row in the array
  meet_period <- list()
  for (k in (1:dim(meet_array)[1])) {
    meet_period[[length(meet_period)+1]]<-which(period_day_mat%*%t(meet_array[k,])==1)
  }
  
  meet_pattern <- unlist(meet_period)
  
  if (length(meet_pattern)==0) {
    # in this case the class does not have meetings from MON-SAT. Possible the class is on SUN, or Online, or has no meeting no room at all (like CSE 2300W - not sure how yet - maybe kind of independent study) 
    ind <- sample(1:n_period, 1)
  } else {
    # instead of ind <- sample(1:n_period, 1), sample from class meeting periods
    if (meet_time_data[i,2]==1){
      # evening class should have evening exam (of the same day the class meets)
      ind <- sample(intersect(evening_period,meet_pattern), 1)     
    }
    else{
      ind <- sample(meet_pattern, 1)       
    }
  }
  
  # if exam is in common block
  if(exam_data[i,5] == 1)
  {
    # check if not already assigned
    if(!any(exam_period_mat[i,] == 1))
    {
      course_id <- exam_data[i,4]
      common_block_exams <- which(exam_data[,4] == course_id)
      for(j in common_block_exams)
      {
        exam_period_mat[j,ind] <- 1
      }
    }
  } else {
    # if not in common block, exam only has itself in its block
    exam_period_mat[i,ind] <- 1
  }
}
  
# initialize assignments for exams to rooms by reading from exam_room_mat, which tells which class meets in which room
exam_room_mat <- matrix(0, nrow=n_exam, ncol=n_room)
for(i in 1:n_exam) {
  # if a room is found for the class meeting
  if (any(exam_room_data[,1]==i)) {
    # Get room_id where the class meets (all, including non cross listed and cross listed exams. Online courses are not included in exam_room_data)
    room_id <- exam_room_data[which(exam_room_data[,1]==i),2]
    exam_room_mat[i,room_id[1]] <- 1  # if there are more than 1 room for the class, select the first room      
  }
}

# Need period to day conversion
period_day_mat <- matrix(0, nrow=n_period, ncol=n_day) 
for (i in 1:n_period) {
  day <- period_data[i,1] # get day given period
  period_day_mat[i,day] <- 1   
}

# Need period to day conversion for 4 exams in 2 consecutive days
period_day_four_exams_two_days_mat <- matrix(0, nrow=n_period, ncol=n_day-1)
for (j in 1:n_day-1) {
  period_day_four_exams_two_days_mat[,j] <- period_day_mat[,j] + period_day_mat[,j+1]  
}

# element = 1 at the intersection of days, 2 in day 1, 1 in day 2
period_three_exams_two_days_1_mat <- matrix(0, nrow=n_period, ncol=n_day-1)
for (i in 1:n_day-1) {
    period_three_exams_two_days_1_mat[i*n_dayperiod-1,i] <- 1 
    period_three_exams_two_days_1_mat[i*n_dayperiod,i] <- 1
    period_three_exams_two_days_1_mat[i*n_dayperiod+1,i] <- 1
}

# defines all periods that occur at intersections of days
three_exams_two_days_1_all_periods <- which(rowSums(period_three_exams_two_days_1_mat)==1)

# element = 1 at the intersection of days, 1 in day 1, 2 in day 2
period_three_exams_two_days_2_mat <- matrix(0, nrow=n_period, ncol=n_day-1)
for (i in 1:n_day-1) {
  period_three_exams_two_days_2_mat[i*n_dayperiod,i] <- 1 
  period_three_exams_two_days_2_mat[i*n_dayperiod+1,i] <- 1
  period_three_exams_two_days_2_mat[i*n_dayperiod+2,i] <- 1
}

# defines all periods that occur at intersections of days
three_exams_two_days_2_all_periods <- which(rowSums(period_three_exams_two_days_2_mat)==1)

# defines which indexes an exam should refer to if cross-listed
# cross-listed exams will all refer to the same index, the index with the smallest exam_id
# uncross-listed exams will refer to their own index
cross_exam_index <- matrix(0, nrow=n_exam, ncol=1)
for(i in 1:n_exam)
{
  #Should differentiate the indexes and the ids 
  exam_id = exam_data[i,1]
  if(exam_id %in% cross_exam_data[,1])
  {
    # If exam is cross-listed
    # index of possible cross listed exam(s) in cross_exam_data
    cross_ind <- which(cross_exam_data[,1]==exam_id)
    
    # this cross_exam_set contains the exam id(s) of the cross listed exam(s), excluding exam_id of the current exam
    cross_exam_set <- cross_exam_data[cross_ind,2]
    
    # exams in the set will map to the minimum id in the set
    cross_exam_index[i] <- which(exam_data[,1] == min(cross_exam_set,exam_id))
  }
  else
  {
    # Exam is not crossed, index of exam should refer to itself
    cross_exam_index[i] <- i
  }
}

# the original indexes of an exam are the rows, the indexs it refers to are the coulumns 
# matrix to either move values from a cross exam into the indexed exam
cross_exam_merge_mat <- diag(n_exam)
# matrix to ignore values from a cross exam whose index is not the indexed exam
cross_exam_ignore_mat <- diag(n_exam)
for(i in 1:n_exam)
{
  if(i != cross_exam_index[i])
  {
    cross_exam_merge_mat[i,i] <- 0
    cross_exam_merge_mat[i, cross_exam_index[i]] <- 1
    cross_exam_ignore_mat[i,i] <- 0
  }
}

is_not_cross_exam_mat <- rowSums(cross_exam_ignore_mat)

# list of indices of all students who take an exam
# which(student_exam_data[,2]==exam_data[i,1]) are the indices of ith exam
# student_exam_data[which(student_exam_data[,2]==exam_data[i,1]),1] are all student ids who take ith exam
# which(student_data[,1] %in% student_exam_data[which(student_exam_data[,2]==exam_data[i,1]),1]) are all student indexes who take ith exam
exam_student_list <- list()
for (i in 1:n_exam) {
  # find all cross-listed exams
  exams <- which(cross_exam_index == i)
  exam_indices <- which(student_exam_data[,2] %in% exam_data[exams,1])
  exam_student_list[[i]] <- which(student_data[,1] %in% student_exam_data[exam_indices,1])
}

# list of indices of all faculty who proctor an exam
exam_instructor_list <- list()
for (i in 1:n_exam) {
  exam_indices <- which(instructor_exam_data[,2] %in% exam_data[i,1])
  exam_instructor_list[[i]] <- which(instructor_data[,1] %in% instructor_exam_data[exam_indices,1])
}

common_block_exam_list <- list()
for(i in 1:n_exam) {
  # if an exam is in common block, keep of list of all other exams with the same course_id
  if(exam_data[i,5] == 1)
  {
    course_id <- exam_data[i,4]
    common_block_exam_list[[i]] <- which(exam_data[,4] == course_id)
  }
  else
  {
    # if not in common block, exam only has itself in its block
    common_block_exam_list[[i]] <- c(i)
  }
}

# Initializes matrices needed for cost computations
# add columns of cross exams together
student_exam_merge_mat <- student_exam_mat%*%(cross_exam_merge_mat)
# if a student takes multiple cross exams, the previous line will cause it to look 
# like a student takes the same exam multiple times. Set such entries to 1.
student_exam_merge_mat[student_exam_merge_mat>=2] <- 1
student_period_mat <- student_exam_merge_mat%*%exam_period_mat
instructor_period_mat <- instructor_exam_mat%*%(cross_exam_ignore_mat%*%exam_period_mat)
exam_room_sufficient_mat <- (t(cross_exam_merge_mat)%*%exam_data[,2] - exam_room_mat%*%room_data[,2])*exam_data[,3]*is_not_cross_exam_mat
room_period_mat <- t(exam_room_mat)%*%(cross_exam_ignore_mat%*%exam_period_mat)
three_exam_same_day_mat <- student_period_mat%*%period_day_mat
four_exam_two_day_mat <- student_period_mat%*%period_day_four_exams_two_days_mat
three_exam_two_day_1_mat <- student_period_mat%*%period_three_exams_two_days_1_mat
three_exam_two_day_2_mat <- student_period_mat%*%period_three_exams_two_days_2_mat

hard_contraints_cost <- function(exam_period_mat,exam_room_mat,student_period_mat,exam_room_sufficient_mat,room_period_mat)  {
  # constraints for 2 exams at the same time 
  two_exam_same_time <- sum(student_period_mat>=2) 
  
  # constraints for faculty members proctoring 2 exams at the same time 
  two_exam_same_time_instructor <- sum(instructor_period_mat>=2) 
  
  # room should suffice exam cap
  exam_room_sufficient <- sum(exam_room_sufficient_mat>0)
  
  # cost to assign 2 exams to same room and same period 
  two_exam_same_room_same_period <- sum(room_period_mat>=2)
  
  # each exam is located to at most 1 room, and to at most 1 period is already there 
  # two exams can not share the same room in 1 same period
  
  return(two_exam_same_time*two_exam_same_time_student_penalty + exam_room_sufficient*exam_room_sufficient_penalty + two_exam_same_room_same_period*two_exam_same_room_same_period_penalty + two_exam_same_time_instructor*two_exam_same_time_instructor_penalty)
}

soft_contraints_cost <- function(exam_period_mat,exam_room_mat,student_period_mat, three_exam_same_day_mat, four_exam_two_day_mat, three_exam_two_day_1_mat, three_exam_two_day_2_mat)  {
  # students should not have >= 3 exams on the same day
  three_exam_same_day <- sum(three_exam_same_day_mat>=3)
  
  # students should not have >= 4 exams in 2 consecutive days
  four_exam_two_day <- sum(four_exam_two_day_mat>=4)
  
  # 3 exams in 2 consecutive days, either case 1 (2 in old_day, 1 in day 2) or case 2 (1 in old_day, 2 in day 2)
  three_exam_consecutive_day <- (sum(three_exam_two_day_1_mat>=3)+sum(three_exam_two_day_2_mat>=3))
  return(three_exam_same_day*three_exam_same_day_penalty + four_exam_two_day*four_exam_two_day_penalty + three_exam_consecutive_day*three_exam_consecutive_day_penalty)
}

cost <- function(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat, three_exam_same_day_mat, four_exam_two_day_mat, three_exam_two_day_1_mat, three_exam_two_day_2_mat){
  cost <- hard_contraints_cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat) + soft_contraints_cost(exam_period_mat, exam_room_mat, student_period_mat, three_exam_same_day_mat, four_exam_two_day_mat, three_exam_two_day_1_mat, three_exam_two_day_2_mat)
  return(cost)
}

check_cost <- function(conflicts_only)  {
  student_period_conflicts <- sum(student_exam_merge_mat%*%exam_period_mat>=2)
  instructor_period_conflicts <- sum((instructor_exam_mat%*%(cross_exam_ignore_mat%*%exam_period_mat))>=2)
  exam_room_sufficient_conflicts <- sum(((t(cross_exam_merge_mat)%*%exam_data[,2] - exam_room_mat%*%room_data[,2])*exam_data[,3]*is_not_cross_exam_mat)>0)
  room_period_conflicts <- sum((t(exam_room_mat)%*%(cross_exam_ignore_mat%*%exam_period_mat))>=2)
  three_exam_same_day_conflicts <- sum(student_exam_merge_mat%*%(exam_period_mat%*%period_day_mat)>=3)
  four_exam_two_days_conflicts <- sum(student_exam_merge_mat%*%(exam_period_mat%*%period_day_four_exams_two_days_mat)>=4)
  three_exam_two_days_1_conflicts <-sum(student_exam_merge_mat%*%(exam_period_mat%*%period_three_exams_two_days_1_mat)>=3)
  three_exam_two_days_2_conflicts <- sum(student_exam_merge_mat%*%(exam_period_mat%*%period_three_exams_two_days_2_mat)>=3)

  # difference <- current_cost - (student_period_conflicts*two_exam_same_time_student_penalty +
  #    instructor_period_conflicts*two_exam_same_time_instructor_penalty +
  #    exam_room_sufficient_conflicts*exam_room_sufficient_penalty +
  #    room_period_conflicts*two_exam_same_room_same_period_penalty +
  #    three_exam_same_day_conflicts*three_exam_same_day_penalty +
  #    four_exam_two_days_conflicts*four_exam_two_day_penalty +
  #    three_exam_two_days_1_conflicts*three_exam_consecutive_day_penalty +
  #    three_exam_two_days_2_conflicts*three_exam_consecutive_day_penalty)

  # if(difference != 0)
  # {
    cat("-----------------\n")
    cat("Differences in cost matrices found:\n")
    # cat("Cost difference: ", difference, "\n")
    if(sum(student_period_mat>=2) != student_period_conflicts | !conflicts_only)
    {
      cat("student_period_mat>=2: Got ", sum(student_period_mat>=2), ", Expected ", student_period_conflicts, "\n")
    }
    if(sum(instructor_period_mat>=2) != instructor_period_conflicts | !conflicts_only)
    {
      cat("instructor_period_mat>=2: Got ", sum(instructor_period_mat>=2), ", Expected ", instructor_period_conflicts, "\n")
    }
    if(sum(exam_room_sufficient_mat>0) != exam_room_sufficient_conflicts | !conflicts_only)
    {
      cat("exam_room_sufficient_mat>0: Got ", sum(exam_room_sufficient_mat>0), ", Expected ", exam_room_sufficient_conflicts, "\n")
    }
    if(sum(room_period_mat>=2) != room_period_conflicts | !conflicts_only)
    {
      cat("room_period_mat>=2: Got ", sum(room_period_mat>=2), ", Expected ", room_period_conflicts, "\n")
    }
    if(sum(three_exam_same_day_mat>=3) != three_exam_same_day_conflicts | !conflicts_only)
    {
      cat("three_exam_same_day_mat>=3: Got ", sum(three_exam_same_day_mat>=3), ", Expected ", three_exam_same_day_conflicts, "\n")
    }
    if(sum(four_exam_two_day_mat>=4) != four_exam_two_days_conflicts | !conflicts_only)
    {
      cat("four_exam_two_day_mat>=4: Got ", sum(four_exam_two_day_mat>=4), ", Expected ", four_exam_two_days_conflicts, "\n")
    }
    if(sum(three_exam_two_day_1_mat>=3) != three_exam_two_days_1_conflicts | !conflicts_only)
    {
      cat("three_exam_two_day_1_mat>=3: Got ", sum(three_exam_two_day_1_mat>=3), ", Expected ", three_exam_two_days_1_conflicts, "\n")
    }
    if(sum(three_exam_two_day_2_mat>=3) != three_exam_two_days_2_conflicts | !conflicts_only)
    {
      cat("three_exam_two_day_2_mat>=3: Got ", sum(three_exam_two_day_2_mat>=3), ", Expected ", three_exam_two_days_2_conflicts, "\n")
    }
    cat("NOTE: Checks for evening_class_exam_penalty and different_day_class_exam_penalty have not been made\n")
    cat("-----------------\n")
  # }
  # else
  # {
  #   cat("OK\n")
  # }
}


# Simple linear cooling (Randelman and Grest)
update_temperature_linear <- function(T,dec,k) {
  return(T-dec)
}

# exponential cooling (Kirkpatrick)
update_temperature_expo <- function(T,k) {
  # return(T*alpha)
  return(T*alpha^k)
}

# Move period of one exam
get_neighbors_period <- function(exam_period_mat, exam_room_mat, exam_id) {
  exam_period_mat_nb <- exam_period_mat
  exam_room_mat_nb <- exam_room_mat
  student_period_mat_nb <- student_period_mat
  instructor_period_mat_nb <- instructor_period_mat
  exam_room_sufficient_mat_nb <- exam_room_sufficient_mat
  room_period_mat_nb <- room_period_mat
  three_exam_same_day_mat_nb <- three_exam_same_day_mat
  four_exam_two_day_mat_nb <- four_exam_two_day_mat
  three_exam_two_day_1_mat_nb <- three_exam_two_day_1_mat
  three_exam_two_day_2_mat_nb <- three_exam_two_day_2_mat
  cost_nb <- current_cost
  
  old_period <- which(exam_period_mat[exam_id,]==1)
  old_day <- (old_period-1)%/%n_dayperiod+1
  
  new_period <- old_period
  # new_period must be a different one
  while (new_period==old_period)  {
    new_period <- sample(1:n_period,1)  
  }  
  
  new_day <- (new_period-1)%/%n_dayperiod+1
  
  # Change all exams in the same block simultaneouly
  for(i in common_block_exam_list[[exam_id]])
  {
    exam_period_mat_nb[i,old_period] <- 0
    exam_period_mat_nb[i,new_period] <- 1
    
    # Changing the ith exam will affect only students who take that exam
    # Only update cost matrices for these students
    for(student_index in exam_student_list[[i]])
    {
      # When the ith exam is removed from a period,
      # the student will have one fewer exam during that period
      student_period_mat_nb[student_index,old_period] <- student_period_mat_nb[student_index,old_period] - 1
      # If the change would free a student of a conflict(# of exams the period goes from 2 -> 1), reduce cost by penalty
      if(student_period_mat_nb[student_index,old_period] == 1)
      {
        cost_nb <- cost_nb - two_exam_same_time_student_penalty
      }
      # When the ith exam is removed from a day,
      # the student will have one fewer exam during that day
      three_exam_same_day_mat_nb[student_index,old_day] <- three_exam_same_day_mat_nb[student_index,old_day] - 1
      # If the change would free a student of three exams in a day(# of exams in day goes from 3 -> 2), reduce cost by penalty
      if(three_exam_same_day_mat_nb[student_index,old_day] == 2)
      {
        cost_nb <- cost_nb - three_exam_same_day_penalty
      }
      # When the ith exam is removed from a day within a two-day period,
      # there will be one fewer exam in that two-day period for the student
      # Exams that occur on the first or last day will fall in only 1 two-day period.
      # Otherwise exam will fall within 2 two-day periods
      for(j in max(old_day-1,1):min(old_day,n_day-1))
      {
        four_exam_two_day_mat_nb[student_index,j] <- four_exam_two_day_mat_nb[student_index,j] - 1
        # If the change would free a student of four exams in two days(# of exams in two days goes from 4 -> 3), reduce cost by penalty
        if(four_exam_two_day_mat_nb[student_index,j] == 3)
        {
          cost_nb <- cost_nb - four_exam_two_day_penalty
        }
      }
      # When the ith exam is removed from a period which occurs 
      # within the periods defined in period_three_exams_two_days_1_mat or period_three_exams_two_days_2_mat,
      # there will be one fewer exam in the respective three-period period the student
      if(old_period %in% three_exams_two_days_1_all_periods)
      {
        three_exam_two_day_1_mat_nb[student_index,(old_period+1)%/%5] <- three_exam_two_day_1_mat_nb[student_index,(old_period+1)%/%5] - 1
        # If the change would free a student of three exams in consecutive days(# of exams goes from 3 -> 2), reduce cost by penalty
        if(three_exam_two_day_1_mat_nb[student_index,(old_period+1)%/%5] == 2)
        {
          cost_nb <- cost_nb - three_exam_consecutive_day_penalty
        }
      }
      if(old_period %in% three_exams_two_days_2_all_periods)
      {
        three_exam_two_day_2_mat_nb[student_index,(old_period)%/%5] <- three_exam_two_day_2_mat_nb[student_index,(old_period)%/%5] - 1
        if(three_exam_two_day_2_mat_nb[student_index,(old_period)%/%5] == 2)
        {
          cost_nb <- cost_nb - three_exam_consecutive_day_penalty
        }
      }
      
      # The following lines are symmetrical to those above, 
      # but instead of removing an exam from a period, we are adding an exam to a period
      # and instead of removing penalties, we add penalties
      student_period_mat_nb[student_index,new_period] <- student_period_mat_nb[student_index,new_period] + 1
      if(student_period_mat_nb[student_index,new_period] == 2)
      {
        cost_nb <- cost_nb + two_exam_same_time_student_penalty
      }
      three_exam_same_day_mat_nb[student_index,new_day] <- three_exam_same_day_mat_nb[student_index,new_day] + 1
      if(three_exam_same_day_mat_nb[student_index,new_day] == 3)
      {
        cost_nb <- cost_nb + three_exam_same_day_penalty
      }
      for(k in max(new_day-1,1):min(new_day,n_day-1))
      {
        four_exam_two_day_mat_nb[student_index,k] <- four_exam_two_day_mat_nb[student_index,k] + 1
        if(four_exam_two_day_mat_nb[student_index,k] == 4)
        {
          cost_nb <- cost_nb + four_exam_two_day_penalty
        }
      }
      if(new_period %in% three_exams_two_days_1_all_periods)
      {
        three_exam_two_day_1_mat_nb[student_index,(new_period+1)%/%5] <- three_exam_two_day_1_mat_nb[student_index,(new_period+1)%/%5] + 1
        if(three_exam_two_day_1_mat_nb[student_index,(new_period+1)%/%5] == 3)
        {
          cost_nb <- cost_nb + three_exam_consecutive_day_penalty
        }
      }
      if(new_period %in% three_exams_two_days_2_all_periods)
      {
        three_exam_two_day_2_mat_nb[student_index,(new_period)%/%5] <- three_exam_two_day_2_mat_nb[student_index,(new_period)%/%5] + 1
        if(three_exam_two_day_2_mat_nb[student_index,(new_period)%/%5] == 3)
        {
          cost_nb <- cost_nb + three_exam_consecutive_day_penalty
        }
      }
    }
    
    # here if a class is in the evening and old_period is in the evening, removing the exam from old_period would increase the cost
    if ((old_period %in% evening_period) & (meet_time_data[i,2]==1)) {
      cost_nb <- cost_nb + evening_class_exam_penalty
    }
    
    # here if an exam is on the same days of class meeting, removing the exam from old_period would increase the cost
    # note that if an evening exam is both in the evening AND on the same days of class meeting, the exam gets both penalties
    if (old_period %in% meet_pattern) {
      cost_nb <- cost_nb + different_day_class_exam_penalty
    }
    
    # the adding/subtracting cost for evening_class_exam_penalty and different_day_class_exam_penalty here is different from other costs below it
    # here if a class is in the evening and old_period is in the evening, adding the exam to new_period would decrease the cost
    if ((new_period %in% evening_period) & (meet_time_data[i,2]==1)) {
      cost_nb <- cost_nb - evening_class_exam_penalty
    }
    
    # here if an exam is on the same days of class meeting, adding the exam to new_period would decrease the cost
    # note that if an evening exam is both in the evening AND on the same days of class meeting, the exam reduces both penalties
    if (new_period %in% meet_pattern) {
      cost_nb <- cost_nb - different_day_class_exam_penalty
    }
    
    if (exam_data[i,3]==1) {
      room <- which(exam_room_mat[i,]==1) 
      # length(which(exam_room_mat[i,]==1)): this is due to some non-WW classes that have no room
      if (length(which(exam_room_mat[i,]==1))!=0)  {
        # When ith exam is removed from a room/period, there is one less exam at that room/period
        room_period_mat_nb[room,old_period] <- room_period_mat_nb[room,old_period] - 1
        # If change would free a conflict (# of exams in room/period goes from 2 -> 1), remove penalty
        if(room_period_mat_nb[room,old_period] == 1)
        {
          cost_nb <- cost_nb - two_exam_same_room_same_period_penalty
        }
        # When ith exam is added from a room/period, there is one more exam at that room/period
        room_period_mat_nb[room,new_period] <- room_period_mat_nb[room,new_period] + 1
        # If change would introduce a conflict (# of exams in room/period goes from 1 -> 2), add penalty
        if(room_period_mat_nb[room,new_period] == 2)
        {
          cost_nb <- cost_nb + two_exam_same_room_same_period_penalty
        }
      }
    }
    
    for(instructor_index in exam_instructor_list[[i]])
    {
      # When the ith exam is removed from a period,
      # the instructor will have one fewer exam during that period
      instructor_period_mat_nb[instructor_index,old_period] <- instructor_period_mat_nb[instructor_index,old_period] - 1
      # If the change would free a instructor of a conflict(# of exams the period goes from 2 -> 1), reduce cost by penalty
      if(instructor_period_mat_nb[instructor_index,old_period] == 1)
      {
        cost_nb <- cost_nb - two_exam_same_time_instructor_penalty
      }
      instructor_period_mat_nb[instructor_index,new_period] <- instructor_period_mat_nb[instructor_index,new_period] + 1
      if(instructor_period_mat_nb[instructor_index,new_period] == 2)
      {
        cost_nb <- cost_nb + two_exam_same_time_instructor_penalty
      }
    }
  }
  
  nb <- list()
  nb$exam_period_mat <- exam_period_mat_nb
  nb$exam_room_mat <- exam_room_mat_nb
  nb$student_period_mat <- student_period_mat_nb
  nb$instructor_period_mat <- instructor_period_mat_nb
  nb$exam_room_sufficient_mat <- exam_room_sufficient_mat_nb
  nb$room_period_mat <- room_period_mat_nb
  nb$three_exam_same_day_mat <- three_exam_same_day_mat_nb
  nb$four_exam_two_day_mat <- four_exam_two_day_mat_nb
  nb$three_exam_two_day_1_mat <- three_exam_two_day_1_mat_nb
  nb$three_exam_two_day_2_mat <- three_exam_two_day_2_mat_nb
  nb$cost <- cost_nb
  return(nb)
}


# Here only schedule exams to rooms where rooms have conflict (more than 1 exam at the same time in the same room)
# exams passed to this function should be only ones that have conflicts
get_neighbors_conflict_room <- function(exam_period_mat, exam_room_mat, exam_id) {
  exam_period_mat_nb <- exam_period_mat
  exam_room_mat_nb <- exam_room_mat
  student_period_mat_nb <- student_period_mat
  instructor_period_mat_nb <- instructor_period_mat
  exam_room_sufficient_mat_nb <- exam_room_sufficient_mat
  room_period_mat_nb <- room_period_mat
  three_exam_same_day_mat_nb <- three_exam_same_day_mat
  four_exam_two_day_mat_nb <- four_exam_two_day_mat
  three_exam_two_day_1_mat_nb <- three_exam_two_day_1_mat
  three_exam_two_day_2_mat_nb <- three_exam_two_day_2_mat
  cost_nb <- current_cost
  
  i <- exam_id
  
  # Here only schedule exams to rooms for in-person courses
  if (exam_data[i,3]==1) {
    old_room <- which(exam_room_mat[i,]==1) 
    
    # get the assigned period of the exam given exam_id
    exam_period <- which(exam_period_mat[exam_id,]==1)
    
    # find a free room 
    new_room_exam_num <- 2
    iter <- 1
    new_room <- old_room
    while ((new_room_exam_num != 0) | (old_room==new_room)) {
      new_room <- sample(1:n_room,1)
      # number of exams in the new room if move this exam there (draw exam_period_mat and exam_room_mat to see it better)
      new_room_exam_num <- length(intersect(which(exam_room_mat[,new_room]==1),which(exam_period_mat[,exam_period]==1)))  
      iter <- iter + 1
      if (iter > 10000) {
        print("Can not find a free room in the given period after many runs")        
        stop("Can not find a free room")
      }
    }    
    exam_room_mat_nb[i,old_room] <- 0
    exam_room_mat_nb[i,new_room] <- 1
    
    # If the old room was not sufficient, remove penalty
    if(exam_room_sufficient_mat_nb[i]>0)
    {
      cost_nb <- cost_nb - exam_room_sufficient_penalty
    }
    # When the ith exam is removed from a room, add the room's student cap back to matrix (return it to # of students taking exam)
    exam_room_sufficient_mat_nb[i] <- exam_room_sufficient_mat_nb[i] + room_data[old_room,2]
    
    # When the ith exam is removed from a room, find difference between # of students taking ith exam and room's cap
    exam_room_sufficient_mat_nb[i] <- exam_room_sufficient_mat_nb[i] - room_data[new_room,2]
    
    # If the new room is not sufficient, add penalty
    if(exam_room_sufficient_mat_nb[i]>0)
    {
      cost_nb <- cost_nb + exam_room_sufficient_penalty
    }
    # else {print("ok")}
    
    # When ith exam is removed from a room/period, there is one less exam at that room/period
    room_period_mat_nb[old_room,exam_period] <- room_period_mat_nb[old_room,exam_period] - 1
    # If change would free a conflict (# of exams in room/period goes from 2 -> 1), remove penalty
    if(room_period_mat_nb[old_room,exam_period] == 1)
    {
      cost_nb <- cost_nb - two_exam_same_room_same_period_penalty
    }
    # When ith exam is added from a room/period, there is one more exam at that room/period
    room_period_mat_nb[new_room,exam_period] <- room_period_mat_nb[new_room,exam_period] + 1
    # If change would introduce a conflict (# of exams in room/period goes from 1 -> 2), add penalty
    if(room_period_mat_nb[new_room,exam_period] == 2)
    {
      cost_nb <- cost_nb + two_exam_same_room_same_period_penalty
    }
  }
  nb <- list()
  nb$exam_period_mat <- exam_period_mat_nb
  nb$exam_room_mat <- exam_room_mat_nb
  nb$student_period_mat <- student_period_mat_nb
  nb$instructor_period_mat <- instructor_period_mat_nb
  nb$exam_room_sufficient_mat <- exam_room_sufficient_mat_nb
  nb$room_period_mat <- room_period_mat_nb
  nb$three_exam_same_day_mat <- three_exam_same_day_mat_nb
  nb$four_exam_two_day_mat <- four_exam_two_day_mat_nb
  nb$three_exam_two_day_1_mat <- three_exam_two_day_1_mat_nb
  nb$three_exam_two_day_2_mat <- three_exam_two_day_2_mat_nb
  nb$cost <- cost_nb  
  return(nb)
}

# Move room of one exam
get_neighbors_room <- function(exam_period_mat, exam_room_mat, i) {
  exam_period_mat_nb <- exam_period_mat
  exam_room_mat_nb <- exam_room_mat
  student_period_mat_nb <- student_period_mat
  exam_room_sufficient_mat_nb <- exam_room_sufficient_mat
  room_period_mat_nb <- room_period_mat
  three_exam_same_day_mat_nb <- three_exam_same_day_mat
  four_exam_two_day_mat_nb <- four_exam_two_day_mat
  three_exam_two_day_1_mat_nb <- three_exam_two_day_1_mat
  three_exam_two_day_2_mat_nb <- three_exam_two_day_2_mat
  cost_nb <- current_cost
  
  # Here only schedule exams to rooms for in-person courses
  if (exam_data[i,3]==1) {
    old_room <- which(exam_room_mat[i,]==1) 
    new_room <- sample(1:n_room,1)
    exam_room_mat_nb[i,old_room] <- 0
    exam_room_mat_nb[i,new_room] <- 1
    
    # If the old room was not sufficient, remove penalty
    if(exam_room_sufficient_mat_nb[i]>0)
    {
      cost_nb <- cost_nb - exam_room_sufficient_penalty
    }
    # When the ith exam is removed from a room, add the room's student cap back to matrix (return it to # of students taking exam)
    exam_room_sufficient_mat_nb[i] <- exam_room_sufficient_mat_nb[i] + room_data[old_room,2]
    # When the ith exam is removed from a room, find difference between # of students taking ith exam and room's cap
    exam_room_sufficient_mat_nb[i] <- exam_room_sufficient_mat_nb[i] - room_data[new_room,2]
    # If the new room is not sufficient, add penalty
    if(exam_room_sufficient_mat_nb[i]>0)
    {
      cost_nb <- cost_nb + exam_room_sufficient_penalty
    }
    
    period <- which(exam_period_mat[i,]==1)
    # When ith exam is removed from a room/period, there is one less exam at that room/period
    room_period_mat_nb[old_room,period] <- room_period_mat_nb[old_room,period] - 1
    # If change would free a conflict (# of exams in room/period goes from 2 -> 1), remove penalty
    if(room_period_mat_nb[old_room,period] == 1)
    {
      cost_nb <- cost_nb - two_exam_same_room_same_period_penalty
    }
    # When ith exam is added from a room/period, there is one more exam at that room/period
    room_period_mat_nb[new_room,period] <- room_period_mat_nb[new_room,period] + 1
    # If change would introduce a conflict (# of exams in room/period goes from 1 -> 2), add penalty
    if(room_period_mat_nb[new_room,period] == 2)
    {
      cost_nb <- cost_nb + two_exam_same_room_same_period_penalty
    }
  }
  
  nb <- list()
  nb$exam_period_mat <- exam_period_mat_nb
  nb$exam_room_mat <- exam_room_mat_nb
  nb$student_period_mat <- student_period_mat_nb
  nb$instructor_period_mat <- instructor_period_mat_nb
  nb$exam_room_sufficient_mat <- exam_room_sufficient_mat_nb
  nb$room_period_mat <- room_period_mat_nb
  nb$three_exam_same_day_mat <- three_exam_same_day_mat_nb
  nb$four_exam_two_day_mat <- four_exam_two_day_mat_nb
  nb$three_exam_two_day_1_mat <- three_exam_two_day_1_mat_nb
  nb$three_exam_two_day_2_mat <- three_exam_two_day_2_mat_nb
  nb$cost <- cost_nb
  return(nb)
}

make_move_period <- function(T)  {
  exam_id <- sample(1:n_exam,1)
  # get index of exam
  exam_id <- cross_exam_index[exam_id]
  # Move one period of an exam
  nb <- get_neighbors_period(exam_period_mat, exam_room_mat, exam_id)
  delta <-  nb$cost - current_cost
  
  if (delta < 0)  {
    nb$moved <- TRUE
    return(nb)
  } else {
    p = exp(-delta/T)
    if (runif(1) < p) {
      nb$moved <- TRUE
      return(nb)
    } else {
      nb$exam_period_mat <- exam_period_mat
      nb$exam_room_mat <- exam_room_mat
      nb$moved <- FALSE
      return(nb)
    }
  }
}

make_move_room <- function(T,exam_id)  {
  # Here only check conflicted exams in room_period_mat matrix
  # Move one period of an exam
  
  nb <- get_neighbors_conflict_room(exam_period_mat, exam_room_mat, exam_id)
  delta <-  nb$cost - current_cost
  if (delta < 0)  {
    nb$moved <- TRUE
    # print(paste("The cost: ",nb$cost))
    
    return(nb)
  } else {
    p = exp(-delta/T)
    if (runif(1) < p) {
      nb$moved <- TRUE
      return(nb)
    } else {
      nb$exam_period_mat <- exam_period_mat
      nb$exam_room_mat <- exam_room_mat
      nb$moved <- FALSE
      return(nb)
    }
  }
}

T <- 10000
alpha <- 0.95 # exponential cooling Tk+1=alpha*Tk
k <- 1
dec <- 0.001
loop <- 100 # loops at any temperature

two_exam_same_time_student_penalty <- 10000
two_exam_same_time_instructor_penalty <- 10000
exam_room_sufficient_penalty <- 10000
two_exam_same_room_same_period_penalty <- 10000

three_exam_same_day_penalty <- 100
four_exam_two_day_penalty <- 100
three_exam_consecutive_day_penalty <- 100
different_day_class_exam_penalty <- 100
evening_class_exam_penalty <- 100

current_cost <- cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat, three_exam_same_day_mat, four_exam_two_day_mat, three_exam_two_day_1_mat, three_exam_two_day_2_mat)
print(current_cost)
print(hard_contraints_cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat))
while (T > 1e-3)  {
  for (i in 1:loop){
    x = make_move_period(T)
    
    if(x$moved == TRUE)  {
      exam_period_mat <- x$exam_period_mat
      exam_room_mat <- x$exam_room_mat
      student_period_mat <- x$student_period_mat
      instructor_period_mat <- x$instructor_period_mat
      room_period_mat <- x$room_period_mat
      exam_room_sufficient_mat <- x$exam_room_sufficient_mat
      three_exam_same_day_mat <- x$three_exam_same_day_mat
      four_exam_two_day_mat <- x$four_exam_two_day_mat
      three_exam_two_day_1_mat <- x$three_exam_two_day_1_mat
      three_exam_two_day_2_mat <- x$three_exam_two_day_2_mat
      current_cost <- x$cost
    }
  }
  print(current_cost)
  print(T)
  T=T-0.1*k
}
print(current_cost)
print(hard_contraints_cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat))

conflict_exam_list <- list()
for(j in 1:n_room) {
  for(k in 1:n_period) {
    if (room_period_mat[j,k]>=2) {
      # now we have conflict: more than 1 exam in the same room at the same time
      # get the exams that conflict in the room at the period
      conflict_exams <- intersect(which(exam_room_mat[,j]==1),which(exam_period_mat[,k]==1))
      # shouldn't have to check for length(conflict_exams)>0, currently now as I did run copying rows from cross-listed exams into the others
      # so just have it here to avoid the case of 2 exams but cross listed. A new run won't need this check
      if (length(conflict_exams)>=2) {
        # leave the 1st exam, now get all others to reschedule rooms, except the 1st exams, and append to the list
        conflict_exam_list[[length(conflict_exam_list)+1]] <- conflict_exams[-1]  
      }
    }
  }
}

#Now tuning rooms
T <- 1000
k <- 10
# unlist/unroll conflict_exam_list as this is a list of arrays
conflict_exam_list <- unlist(conflict_exam_list)
n_conflict_exam <- length(conflict_exam_list)
#current_cost <- cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat, three_exam_same_day_mat, four_exam_two_day_mat, three_exam_two_day_1_mat, three_exam_two_day_2_mat)

while (T > 1e-3)  {
  for (i in 1:n_conflict_exam){
    # try to move the conflict exam to another room
    exam_id <- conflict_exam_list[i]
    x = make_move_room(T,exam_id)

    if(x$moved == TRUE)  {
      exam_period_mat <- x$exam_period_mat
      exam_room_mat <- x$exam_room_mat
      student_period_mat <- x$student_period_mat
      instructor_period_mat <- x$instructor_period_mat
      room_period_mat <- x$room_period_mat
      exam_room_sufficient_mat <- x$exam_room_sufficient_mat
      three_exam_same_day_mat <- x$three_exam_same_day_mat
      four_exam_two_day_mat <- x$four_exam_two_day_mat
      three_exam_two_day_1_mat <- x$three_exam_two_day_1_mat
      three_exam_two_day_2_mat <- x$three_exam_two_day_2_mat
      current_cost <- x$cost
    }
  }
  print(current_cost)
  print(T)
  T=T-k
}
print(current_cost)
print(hard_contraints_cost(exam_period_mat, exam_room_mat, student_period_mat, exam_room_sufficient_mat, room_period_mat))

# copy rows from cross-listed exams into the others
for(i in 1:n_exam)
{
  if(i != cross_exam_index[i])
  {
    exam_period_mat[i,] <- exam_period_mat[cross_exam_index[i],]
    exam_room_mat[i,] <- exam_room_mat[cross_exam_index[i],]
  }
}

#check_cost(conflicts_only=FALSE)

save.image(file = "solution.RData")
#save.image(file = "solution_room_optimized_no_evening_no_same_day_0_1_cooling.RData")

# now export the solution to text files
exam_solution <- matrix(0, nrow=n_exam, ncol=4)
names(exam_solution) <- c("exam_id","period_id","room_id","combined")
for (i in (1:n_exam)) {
  exam_solution[i,1] <- i
  exam_solution[i,2] <- which(exam_period_mat[i,]==1)
  room <- which(exam_room_mat[i,]==1)
  if (length(room)>0) {
    exam_solution[i,3] <- room   
  }
  if (i!=cross_exam_index[i,1]) {
    exam_solution[i,4] <- 1   
  }
}

write.csv(exam_solution, file = "Spring16_solution.csv")