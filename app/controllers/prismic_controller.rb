# The necessary methods your controller needs to use prismic.io transparently
module PrismicController

  private


  def redirect_to_signin
    redirect_to signin_path
  end

  # Setting @ref as the actual ref id being queried, even if it's the master ref.
  # To be used to call the API, for instance: api.form('everything').submit(ref).
  # Note that this is the ref ID (the "ref" field of a ref), the one to be used to query.
  def ref
    @ref ||= (params[:ref].blank? ? api.master_ref.ref : api.refs.select{|_, ref| ref.id == params[:ref]}.values[0].ref)
  end

  # Setting @maybe_ref as the ref id being queried, or nil if it is the master ref.
  # To be used where you want nothing if on master, but something if on another release.
  # For instance:
  #  * you can use it to call Rails routes: document_path(ref: maybe_ref), which will add "?ref=refid" as a param, but only when needed.
  #  * you can pass it to your link_resolver method, which will use it accordingly.
  # Note that this is the release ID (the "is" field of a ref), the one to be used in your URL.
  def maybe_ref
    @maybe_ref ||= (params[:ref].blank? ? nil : params[:ref])
  end

  ##

  # Easier access and initialization of the Prismic::API object.
  def api
    @api ||= PrismicService.init_api(access_token)
  rescue Prismic::API::PrismicWSAuthError => e
    reset_access_token!
    raise e
  end

  def access_token
    @access_token = session['ACCESS_TOKEN']
  end

  def reset_access_token!
    @access_token = session['ACCESS_TOKEN'] = nil
  end

end
