CREATE TABLE `acquisitions` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) default NULL,
  `person_id` int(11) default NULL,
  `method` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `person_id` (`person_id`,`sample_id`),
  KEY `acquisitions_person` (`person_id`),
  KEY `acquisitions_sample` (`sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=721 DEFAULT CHARSET=latin1;

CREATE TABLE `assays` (
  `id` int(11) NOT NULL auto_increment,
  `isb_assay_id` varchar(255) default NULL,
  `media_id` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `vendor` varchar(255) default NULL,
  `assay_type` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `technology` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `date_received` date default NULL,
  `date_transferred` date default NULL,
  `dated_backup` date default NULL,
  `qc_pass_date` date default NULL,
  `current` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=686 DEFAULT CHARSET=latin1;

CREATE TABLE `assemblies` (
  `id` int(11) NOT NULL auto_increment,
  `genome_reference_id` int(11) default NULL,
  `assay_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `location` varchar(255) default NULL,
  `file_type` varchar(255) default NULL,
  `file_date` date default NULL,
  `status` varchar(50) default NULL,
  `metadata` text,
  `disk_id` varchar(50) default NULL,
  `software` varchar(255) default NULL,
  `software_version` varchar(255) default NULL,
  `record_date` date default NULL,
  `current` tinyint(1) default NULL,
  `comments` text,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `ancestry` varchar(255) default NULL,
  `coverage_data` datetime default NULL,
  `statistics` datetime default NULL,
  `bed_file` datetime default NULL,
  `isb_assembly_id` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1068 DEFAULT CHARSET=latin1;

CREATE TABLE `assembly_files` (
  `id` int(11) NOT NULL auto_increment,
  `genome_reference_id` int(11) default NULL,
  `assembly_id` int(11) default NULL,
  `file_type_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `location` varchar(255) default NULL,
  `file_date` date default NULL,
  `metadata` text,
  `disk_id` varchar(50) default NULL,
  `software` varchar(255) default NULL,
  `software_version` varchar(255) default NULL,
  `record_date` date default NULL,
  `current` tinyint(1) default NULL,
  `comments` text,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `ancestry` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4901 DEFAULT CHARSET=latin1;

CREATE TABLE `audits` (
  `id` int(11) NOT NULL auto_increment,
  `auditable_id` int(11) default NULL,
  `auditable_type` varchar(255) default NULL,
  `association_id` int(11) default NULL,
  `association_type` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `user_type` varchar(255) default NULL,
  `username` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `audited_changes` text,
  `version` int(11) default '0',
  `comment` varchar(255) default NULL,
  `remote_address` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `association_index` (`association_id`,`association_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `diagnoses` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` int(11) default NULL,
  `disease_id` int(11) default NULL,
  `age_of_onset` varchar(50) default NULL,
  `disease_information` text,
  `output_order` int(11) default NULL,
  `created_at` date default NULL,
  `updated_at` date default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `person_id` (`person_id`,`disease_id`)
) ENGINE=MyISAM AUTO_INCREMENT=373 DEFAULT CHARSET=latin1;

CREATE TABLE `diseases` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `omim_id` varchar(255) default NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

CREATE TABLE `file_types` (
  `id` int(11) NOT NULL auto_increment,
  `type_name` varchar(50) default NULL,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

CREATE TABLE `genome_references` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `build_name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `code` varchar(255) default NULL,
  `location` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `memberships` (
  `id` int(11) NOT NULL auto_increment,
  `pedigree_id` int(11) default NULL,
  `person_id` int(11) default NULL,
  `draw_duplicate` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `pedigree_id` (`pedigree_id`,`person_id`),
  KEY `membership_person` (`person_id`),
  KEY `membership_pedigree` (`pedigree_id`)
) ENGINE=InnoDB AUTO_INCREMENT=990 DEFAULT CHARSET=latin1;

CREATE TABLE `pedigrees` (
  `id` int(11) NOT NULL auto_increment,
  `isb_pedigree_id` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `tag` varchar(255) default NULL,
  `study_id` int(11) default NULL,
  `directory` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `version` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `genotype_vector` datetime default NULL,
  `quartet` datetime default NULL,
  `autozygosity_hmm` datetime default NULL,
  `relation_pairing` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_pedigrees_on_name_and_tag` (`name`,`tag`),
  KEY `pedigrees_isb_pedigree_id` (`isb_pedigree_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=latin1;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `isb_person_id` varchar(255) default NULL,
  `collaborator_id` varchar(255) default NULL,
  `gender` varchar(255) default NULL,
  `dob` date default NULL,
  `dod` date default NULL,
  `deceased` tinyint(1) NOT NULL default '0',
  `planning_on_sequencing` tinyint(1) default '0',
  `complete` tinyint(1) default NULL,
  `root` tinyint(1) default NULL,
  `comments` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_people_on_isb_person_id` (`isb_person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=985 DEFAULT CHARSET=latin1;

CREATE TABLE `person_aliases` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `value` varchar(255) default NULL,
  `alias_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `alias_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;

CREATE TABLE `phenotypes` (
  `id` int(11) NOT NULL auto_increment,
  `disease_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `phenotype_type` varchar(255) default NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=latin1;

CREATE TABLE `relationships` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `person_id` int(11) default NULL,
  `relation_id` int(11) default NULL,
  `relationship_type` varchar(255) default NULL,
  `relation_order` int(11) default NULL,
  `divorced` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `person_id` (`person_id`,`relation_id`,`relationship_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2459 DEFAULT CHARSET=latin1;

CREATE TABLE `report_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `reports` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `report_type_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `sample_assays` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) default NULL,
  `assay_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`assay_id`),
  KEY `sample_assays_sample` (`sample_id`),
  KEY `sample_assays_assay` (`assay_id`)
) ENGINE=InnoDB AUTO_INCREMENT=687 DEFAULT CHARSET=latin1;

CREATE TABLE `sample_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `tissue` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

CREATE TABLE `samples` (
  `id` int(11) NOT NULL auto_increment,
  `isb_sample_id` varchar(255) default NULL,
  `customer_sample_id` varchar(255) default NULL,
  `sample_type_id` int(11) default NULL,
  `sample_vendor_id` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `date_submitted` date default NULL,
  `protocol` varchar(255) default NULL,
  `volume` varchar(25) default NULL,
  `concentration` varchar(25) default NULL,
  `quantity` varchar(25) default NULL,
  `date_received` date default NULL,
  `description` text,
  `comments` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `samples_isb_sample_id` (`isb_sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=702 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `studies` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `tag` varchar(50) default NULL,
  `lead` varchar(255) default NULL,
  `collaborator` varchar(255) default NULL,
  `collaborating_institution` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `contact` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

CREATE TABLE `temp_objects` (
  `id` int(11) NOT NULL auto_increment,
  `trans_id` int(11) default NULL,
  `object_type` varchar(255) default NULL,
  `object` text,
  `added` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=582 DEFAULT CHARSET=latin1;

CREATE TABLE `traits` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` int(11) default NULL,
  `phenotype_id` int(11) default NULL,
  `trait_information` varchar(255) default NULL,
  `output_order` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `person_id` (`person_id`,`phenotype_id`)
) ENGINE=InnoDB AUTO_INCREMENT=450 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('20110819233419');

INSERT INTO schema_migrations (version) VALUES ('20110824205929');

INSERT INTO schema_migrations (version) VALUES ('20110904211003');

INSERT INTO schema_migrations (version) VALUES ('20110926182022');