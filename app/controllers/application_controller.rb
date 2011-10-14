class ApplicationController < ActionController::Base
  protect_from_forgery

    # takes an array of arrays.
  def to_madeline(rels)
    logger.debug("in to_madeline")
    tree = {}
    logger.debug("self is #{rels}")
    rels.each do |rel|
      p = rel.person
      c = rel.relation
      logger.debug("p is #{p.inspect}")
      tree[p] ||= {:value => p}
      tree[p][:children] ||= Set.new
      tree[c] ||= {:value => c}
      tree[c][:parent] = tree[p]
      tree[p][:children] << tree[c]
    end
    tree.values.find{|e| e[:parent].nil?}
    logger.debug("tree is #{tree.inspect}")
    logger.debug("one is #{tree[1][:children].inspect}")
  end

end
