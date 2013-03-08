FactoryGirl.define do
  factory(:relationship, aliases: [:husband]) do |r|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    r.relationship_type "undirected"
    r.name "husband"
    r.relation_order "1"
  end

  factory(:wife) do |w|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    w.relationship_type "undirected"
    w.name "wife"
    w.relation_order "1"
  end

  factory(:wife_divorced) do |w|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    w.relationship_type "undirected"
    w.name "wife"
    w.relation_order "1"
    w.divorced "1"
  end

  factory(:daughter) do |d|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    d.relationship_type "child"
    d.name "daughter"
    d.relation_order "2"
  end

  factory(:son) do |s|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    s.relationship_type "child"
    s.name "son"
    s.relation_order "1"
  end

  factory(:mother) do |m|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    m.relationship_type "parent"
    m.name "mother"
    m.relation_order "1"
  end

  factory(:father) do |f|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    f.relationship_type "parent"
    f.name "father"
    f.relation_order "1"
  end

  factory(:monozygotic_twin) do |mt|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    mt.relationship_type "undirected"
    mt.name "monozygotic_twin"
    mt.relation_order "1"
  end

  factory(:dizygotic_twin) do |dt|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:relation_id) { |n| "#{n}" }
    dt.relationship_type "undirected"
    dt.name "dizygotic_twin"
    dt.relation_order "1"
  end

end
