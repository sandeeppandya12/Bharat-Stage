module BxBlockProfile
  class UserCourseExam < BxBlockProfile::ApplicationRecord
    self.table_name = :user_course_exams
# Protected Area Start
    belongs_to :course, class_name: "BxBlockProfile::Course", optional: true
    belongs_to :theme, class_name: "BxBlockProfile::Theme", optional: true
    belongs_to :account, class_name: "AccountBlock::Account", optional: true
    belongs_to :quiz_and_mock_exam, class_name: "BxBlockQuizAndMockExams::QuizAndMockExam", optional: true
    belongs_to :flash_card, class_name: "BxBlockFlashCards::FlashCard", optional: true
    belongs_to :lesson, class_name: "BxBlockProfile::Lesson", optional: true
    belongs_to :quiz_and_answer_polling, class_name: "BxBlockPolling::QuizAndAnswerPolling", optional: true
# Protected Area End
    after_destroy     :check_user_course_status

    def check_user_course_status
      if (!self.exam_type == "flash_cards" && !self.exam_type == "mock_exam") || self.exam_type == "lesson" || self.exam_type == "quiz_exam"
        theme = BxBlockProfile::Theme.find_by({id: self.theme.id})
        course = theme.course
        if course.present?
          user_courses =  BxBlockProfile::UserCourse.where(course_id: course.id)
          total_flash_card_count = theme.flash_cards.count
          total_lessons_count = theme.lessons.count
          total_quiz_and_mock_exams_count = theme.quiz_and_mock_exams.where(exam_type: "quiz_exam").count
          total_count = total_flash_card_count + total_lessons_count + total_quiz_and_mock_exams_count
          user_courses.each do |user_course|
            account = user_course.account
            user_lessons_count = BxBlockProfile::UserCourseExam.where(account_id: account.id, theme_id: theme.id, status: "complete", exam_type: "lesson").count
            user_flash_cards_count = BxBlockProfile::UserCourseExam.where(account_id: account.id, theme_id: theme.id, exam_type: "flash_cards").count
            user_quiz_exam_count = BxBlockProfile::UserCourseExam.where(account_id: account.id, theme_id: theme.id, exam_type: "quiz_exam").count
            user_count = user_lessons_count + user_flash_cards_count + user_quiz_exam_count
            check_user_completion_status(total_count, user_count, user_course, account)
          end
        end
      else
        if self.exam_type == "mock_exam"
          course = self.course
          if course.present?
            user_courses =  BxBlockProfile::UserCourse.where(course_id: course.id)
            user_courses.each do |user_course|
              account = user_course.account
              total_count = course.quiz_and_mock_exams.where(exam_type: "mock_exam").count
              user_count = BxBlockProfile::UserCourseExam.where(account_id: account.id, course_id: course.id, exam_type: "mock_exam", status: "complete").count
              check_user_mock_exam_completion_status(total_count, user_count, user_course, account)
            end
          end
        end
      end
    end

    def check_user_completion_status(total_count, user_count, user_course, account)
      if (total_count != 0 && user_count == 0) && user_course.completion == "complete"
        user_course.update(completion:"inprogress", account_id: account.id )
        theme_leader_board_history = BxBlockProfile::LeaderBoardHistory.where(theme_id: theme.id, account_id: account.id)
        course_leader_board_history = BxBlockProfile::LeaderBoardHistory.where(course_id: course.id, account_id: account.id)
        theme_leader_board_history.destroy_all if theme_leader_board_history.present?
        course_leader_board_history.destroy_all if course_leader_board_history.present?
        all_point = [1]
        if theme.point != 0
          all_point << theme.point
        else
          all_point << 5
        end
        if course.point.to_i != 0
          all_point << course.point
        else
          all_point << 10
        end
        reward_point = account.leader_board.reward_point
        point = reward_point - all_point.sum
        account.leader_board.update(reward_point: point)
        account.leader_board.update(reward_point: 0) if account.leader_board.reward_point < 0
      else
        reward_point = account.leader_board.reward_point
        point = reward_point - 1
        account.leader_board.update(reward_point: point)
        account.leader_board.update(reward_point: 0) if account.leader_board.reward_point < 0
      end
    end

    def check_user_mock_exam_completion_status(total_count, user_count, user_course, account)
      if (total_count == 0 && user_count == 0) && user_course.completion == "complete"
        user_course.update(completion:"inprogress", account_id: account.id )
        all_point = [1]
        if course.point.to_i != 0
          all_point << course.point
        else
          all_point << 10
        end
        reward_point = account.leader_board.reward_point
        point = reward_point - all_point.sum
        account.leader_board.update(reward_point: point)
        account.leader_board.update(reward_point: 0) if account.leader_board.reward_point < 0
      else
        reward_point = account.leader_board.reward_point
        point = reward_point - 1
        account.leader_board.update(reward_point: point)
        account.leader_board.update(reward_point: 0) if account.leader_board.reward_point < 0
      end
    end
  end
end
