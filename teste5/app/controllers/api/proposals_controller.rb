# app/controllers/api/proposals_controller.rb
class Api::ProposalsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:organize_conference]
   
    def organize_conference
        file_path = Rails.root.join('public', 'proposals.txt')
        proposals = read_proposals_from_file(file_path)
        organized_schedule = organize_proposals(proposals)
        render json: organized_schedule
      end
  
    private
    
    def read_proposals_from_file(file_path)
        File.readlines(file_path).map do |line|
          title, duration = line.chomp.split(' ', 2)
          { title: title, duration: duration }
        end
      end   



    def organize_proposals(proposals)
      morning_sessions = organize_sessions(proposals.select { |proposal| proposal[:duration] != 'lightning' }, 'morning', 'A')
      afternoon_sessions = organize_sessions(proposals.select { |proposal| proposal[:duration] != 'lightning' }, 'afternoon', 'A')
      evening_sessions = organize_sessions(proposals.select { |proposal| proposal[:duration] == 'lightning' }, 'evening', 'B')
  
      {
        track_A: {
          morning_sessions: morning_sessions,
          afternoon_sessions: afternoon_sessions
        },
        track_B: {
          evening_sessions: evening_sessions
        },
        networking_event: '17:00 Evento de Networking'
      }
    end
  
    def organize_sessions(proposals, period, track)
      sessions = []
      current_time = (period == 'morning' ? 9 : period == 'afternoon' ? 13 : 17) * 60
  
      while !proposals.empty?
        current_session = {
          start_time: format_time(current_time),
          talks: []
        }
        remaining_time = (period == 'morning' ? 180 : period == 'afternoon' ? 240 : 60)
  
        proposals.each do |proposal|
          if proposal[:duration] == 'lightning'
            proposal_duration = 5
          else
            proposal_duration = proposal[:duration].to_i
          end
  
          if proposal_duration <= remaining_time
            current_session[:talks] << {
              title: proposal[:title],
              duration: proposal[:duration]
            }
            current_time += proposal_duration
            remaining_time -= proposal_duration
            proposals.delete(proposal)
          end
        end
  
        sessions << current_session
      end
  
      sessions
    end
  
    def format_time(minutes)
      hours = minutes / 60
      minutes = minutes % 60
      format('%02d:%02d', hours, minutes)
    end
  end
  