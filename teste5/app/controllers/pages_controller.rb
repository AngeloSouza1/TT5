class PagesController < ApplicationController
  TEMP_UPLOAD_DIR = Rails.root.join('tmp', 'uploads')
  before_action :ensure_temp_upload_dir
  
  
  def home
  end

  def upload_proposals
    uploaded_file = params[:proposals_file]

    if uploaded_file
      temp_file_path = File.join(TEMP_UPLOAD_DIR, uploaded_file.original_filename)

      File.open(temp_file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      flash[:success] = 'Arquivo de propostas enviado com sucesso!'
    else
      flash[:error] = 'Erro ao processar o arquivo de propostas.'
    end

    redirect_to root_path
  end


  private

  def ensure_temp_upload_dir
    FileUtils.mkdir_p(TEMP_UPLOAD_DIR) unless File.directory?(TEMP_UPLOAD_DIR)
  end
end






