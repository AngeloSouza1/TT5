# app/controllers/api/proposals_controller.rb

class Api::ProposalsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:organize_conference]

  def organize_conference
    file_path = Rails.root.join('tmp', 'uploads', 'proposals.txt')
    proposals = read_proposals_from_file(file_path)
    organized_schedule = organize_proposals(proposals)
    render json: organized_schedule
  end

  private

  def read_proposals_from_file(file_path)
    File.readlines(file_path).map do |line|
      match_data = line.chomp.match(/^(.+) (\d+min)?$/)

      if match_data
        title = match_data[1].strip
        duration = match_data[2] ? "#{match_data[2]}min" : 'lightning'
        { title: title, duration: duration }
      else
        { title: line.chomp.strip, duration: 'lightning' }
      end
    end
  end


def organize_proposals(proposals)
  lightning_proposals = proposals.select { |proposal| proposal[:duration] == 'lightning' }
  regular_proposals = proposals - lightning_proposals

  track_a_schedule = organize_track_schedule(regular_proposals, 'A')
  track_b_schedule = organize_track_schedule(regular_proposals + lightning_proposals, 'B')

  {
    track_A: track_a_schedule.merge(networking_event: "17:00 Evento de Networking"),
    track_B: track_b_schedule.merge(networking_event: "17:00 Evento de Networking")
  }
end


 def organize_track_schedule(proposals, track)
  morning_sessions = organize_sessions(proposals, 'morning', track)
  afternoon_sessions = organize_sessions(proposals, 'afternoon', track)

  if track == 'B'
    lightning_proposals = proposals.select { |proposal| proposal[:duration] == 'lightning' }

    lightning_sessions = lightning_proposals.map do |lightning_proposal|
      {
        title: lightning_proposal[:title],
        duration: 'lightning',
        start_time: nil 
      }
    end

    afternoon_sessions.concat(lightning_sessions)
  end

  {
    start_time: '09:00',
    talks: format_sessions(morning_sessions) + [
      { title: 'Almoço', duration: '60min' }
    ] + format_sessions(afternoon_sessions)
  }
end



  def organize_sessions(proposals, period, track)
    sessions = []
    current_time = (period == 'morning' ? 9 : 13) * 60

    while !proposals.empty? && current_time < (period == 'morning' ? 12 : 17) * 60
      current_session = {
        title: '',
        duration: 0,
        start_time: format_time(current_time)
      }

      remaining_time = (period == 'morning' ? 180 : 240)

      proposals.each do |proposal|
        proposal_duration = (proposal[:duration] == 'lightning' ? 5 : proposal[:duration].to_i)

        if proposal_duration <= remaining_time
          current_session[:title] = proposal[:title]
          current_session[:duration] = proposal_duration
          remaining_time -= proposal_duration
          proposals.delete(proposal)
          break
        end
      end

      sessions << current_session.dup
      current_time += current_session[:duration].to_i
    end

    sessions.map! do |session|
      session[:duration] = session[:duration].to_i
      session
    end

    sessions
  end

  def format_sessions(sessions)
    sessions.each do |session|
      session[:title] = session[:title].strip
      session[:duration] = format_time(session[:duration])
    end
  end

  def format_time(minutes)
    hours = minutes.to_f / 60
    minutes = minutes % 60
    format('%02d:%02d', hours.to_i, minutes.to_i)
  end
end
