class UploadPolicy < ApplicationPolicy
  def batch?
    unbanned?
  end

  def image_proxy?
    unbanned?
  end

  def preprocess?
    unbanned?
  end

  def permitted_attributes
    %i[file source tag_string rating status parent_id artist_commentary_title
       artist_commentary_desc include_artist_commentary referer_url
       md5_confirmation as_pending translated_commentary_title translated_commentary_desc]
  end
end
