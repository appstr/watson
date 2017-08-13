class QuestionsController < ApplicationController
  before_action :authenticate_user!

  def ask_questions
    if not_enough_time_passed?
      flash[:notice] = "You must wait at least an hour before testing again."
      return redirect_to users_path
    end
    @questions = Question::QUESTIONS_ENUM
  end

  def submit_questions
    if not_enough_time_passed?
      flash[:notice] = "You must wait at least an hour before testing again."
      return redirect_to users_path
    end
    remove_previous_questions_and_answers
    @questions = Question::QUESTIONS_ENUM
    l = Question::QUESTIONS_ENUM.length
    token_response = get_watson_tone_token
    cu_questions = []
    while l > 0 do
      q = ERB::Util.url_encode(params["question_#{l}"])
      tone_response = get_tone_response(token_response, q)
      if tone_response.response_code == 200
        gather_tone_response_scores(JSON.parse(tone_response.response_body))
        question = Question.new
        question[:user_id] = current_user[:id]
        question[:question_id] = l
        question[:response] = tone_response.response_body
        question[:emotional_tone_1] = Tone::EMOTIONAL_ENUM.key(@emotional_tone_1)
        question[:emotional_tone_2] = Tone::EMOTIONAL_ENUM.key(@emotional_tone_2)
        question[:language_tone_1] = Tone::LANGUAGE_ENUM.key(@language_tone_1)
        question[:language_tone_2] = Tone::LANGUAGE_ENUM.key(@language_tone_2)
        question[:social_tone_1] = Tone::SOCIAL_ENUM.key(@social_tone_1)
        question[:social_tone_2] = Tone::SOCIAL_ENUM.key(@social_tone_2)
        if question.save
          cu_questions << question
        else
          flash[:notice] = "Something went wrong. Please try again..."
          return render "ask_questions"
        end
      else
        flash[:notice] = "Something went wrong. Please try again..."
        return render "ask_questions"
      end
      l -= 1
    end # end -> while l > 0 do
    save_top_tone_answers(cu_questions)
    return redirect_to users_path
  end

  private

  def remove_previous_questions_and_answers
    all_qs = Question.where(user_id: current_user.id)
    all_qs.delete_all if !all_qs.blank?
    top_answers = TopAnswer.where(user_id: current_user.id).first
    top_answers.delete if !top_answers.nil?
  end

  def save_top_tone_answers(cu_questions)
    els = group_tone_answers(cu_questions)
    get_top_tone_answers(els[0], els[1], els[2])
    top_answers = TopAnswer.new
    top_answers[:user_id] = current_user[:id]
    top_answers[:top_emotional_tone] = @e_top
    top_answers[:top_language_tone] = @l_top
    top_answers[:top_social_tone] = @s_top
    begin
      top_answers.save!
    rescue
      puts "RAILS_ERROR: Problem saving top_answers for #{current_user}"
    end
  end

  def group_tone_answers(cu_questions)
    e = []
    l = []
    s = []
    cu_questions.each do |obj|
      e << obj[:emotional_tone_1]
      e << obj[:emotional_tone_2]
      l << obj[:language_tone_1]
      l << obj[:language_tone_2]
      s << obj[:social_tone_1]
      s << obj[:social_tone_2]
    end
    [e,l,s]
  end

  def get_top_tone_answers(e, l, s)
    freq_e = e.inject(Hash.new(0)){|h, v| h[v] += 1; h}
    @e_top = freq_e.max_by{|k,v| v}.first

    freq_l = l.inject(Hash.new(0)){|h, v| h[v] += 1; h}
    @l_top = freq_l.max_by{|k,v| v}.first

    freq_s = s.inject(Hash.new(0)){|h, v| h[v] += 1; h}
    @s_top = freq_s.max_by{|k,v| v}.first
  end

  def not_enough_time_passed?
    q1 = Question.where(user_id: current_user, question_id: 1).first
    return false if q1.nil?
    offset = Time.now - q1[:created_at]
    minutes = offset / 60
    if minutes < 60
      return true
    else
      return false
    end
  end

  def gather_tone_response_scores(response)
    emotional_scores = {
      anger: 0,
      disgust: 0,
      fear: 0,
      joy: 0,
      sadness: 0,
    }
    language_scores = {
      analytical: 0,
      confident: 0,
      tentative: 0,
    }
    social_scores = {
      openness: 0,
      conscientiousness: 0,
      extraversion: 0,
      agreeableness: 0,
      emotional_range: 0
    }
    response["sentences_tone"].each do |tc|
      tc["tone_categories"].each do |tn|
        tn["tones"].each do |t|
          case t["tone_id"]
            when "anger"
              emotional_scores[:anger] += t["score"]
            when "disgust"
              emotional_scores[:disgust] += t["score"]
            when "fear"
              emotional_scores[:fear] += t["score"]
            when "joy"
              emotional_scores[:joy] += t["score"]
            when "sadness"
              emotional_scores[:sadness] += t["score"]
            when "analytical"
              language_scores[:analytical] += t["score"]
            when "confident"
              language_scores[:confident] += t["score"]
            when "tentative"
              language_scores[:tentative] += t["score"]
            when "openness_big5"
              social_scores[:openness] += t["score"]
            when "conscientiousness_big5"
              social_scores[:conscientiousness] += t["score"]
            when "extraversion_big5"
              social_scores[:extraversion] += t["score"]
            when "agreeableness_big5"
              social_scores[:agreeableness] += t["score"]
            when "neuroticism_big5"
              social_scores[:emotional_range] += t["score"]
          end # case
        end # tn["tones"]
      end # tc["tone_categories"]
    end # response["sentence_tone"]
    get_winning_scores(emotional_scores, language_scores, social_scores)
  end

  def get_winning_scores(emotional_scores, language_scores, social_scores)
    e_sorted = emotional_scores.sort_by{|k,v| v}
    @emotional_tone_1 = e_sorted[-1][0].to_s
    @emotional_tone_2 = e_sorted[-2][0].to_s

    l_sorted = language_scores.sort_by{|k,v| v}
    @language_tone_1 = l_sorted[-1][0].to_s
    @language_tone_2 = l_sorted[-2][0].to_s

    s_sorted = social_scores.sort_by{|k,v| v}
    @social_tone_1 = s_sorted[-1][0].to_s
    @social_tone_2 = s_sorted[-2][0].to_s
  end

  def get_tone_response(token_response, q)
    Typhoeus::Request.new(
      "#{ENV['watson_tone_url']}/v3/tone",
      method: :get,
      params: { text: q, version: "2016-05-16" },
      headers: { "Content-Type" => "application/json", "X-Watson-Authorization-Token" => token_response.response_body}
    ).run
  end

  def get_watson_tone_token
    Typhoeus::Request.get("#{ENV['watson_gateway_token_url']}?url=#{ENV['watson_tone_url']}", userpwd: "#{ENV['watson_tone_username']}:#{ENV['watson_tone_password']}")
  end
end
