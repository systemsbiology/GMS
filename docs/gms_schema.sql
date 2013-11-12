-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: gms_production
-- ------------------------------------------------------
-- Server version	5.1.69-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `acquisitions`
--

DROP TABLE IF EXISTS `acquisitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acquisitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `method` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`,`sample_id`),
  KEY `acquisitions_person` (`person_id`),
  KEY `acquisitions_sample` (`sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assays`
--

DROP TABLE IF EXISTS `assays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isb_assay_id` varchar(255) DEFAULT NULL,
  `media_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `vendor` varchar(255) DEFAULT NULL,
  `assay_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `technology` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `date_received` date DEFAULT NULL,
  `date_transferred` date DEFAULT NULL,
  `dated_backup` date DEFAULT NULL,
  `qc_pass_date` date DEFAULT NULL,
  `current` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assemblies`
--

DROP TABLE IF EXISTS `assemblies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assemblies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `genome_reference_id` int(11) DEFAULT NULL,
  `assay_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `isb_assembly_id` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `file_type` varchar(255) DEFAULT NULL,
  `file_date` date DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `metadata` text,
  `disk_id` varchar(50) DEFAULT NULL,
  `software` varchar(255) DEFAULT NULL,
  `software_version` varchar(255) DEFAULT NULL,
  `record_date` date DEFAULT NULL,
  `current` tinyint(1) DEFAULT NULL,
  `comments` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `coverage_data_date` datetime DEFAULT NULL,
  `qa_data_date` datetime DEFAULT NULL,
  `bed_file_date` datetime DEFAULT NULL,
  `genotype_file_date` datetime DEFAULT NULL,
  `COVERAGE_Alltypes_Fully_Called_Percent` float DEFAULT NULL,
  `COVERAGE_Alltypes_Partially_Called_Percent` float DEFAULT NULL,
  `COVERAGE_Alltypes_No_Called_Percent` float DEFAULT NULL,
  `COVERAGE_Alltypes_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Alltypes_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Alltypes_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Exon_Any_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Unclassified_Any_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Simple_Low_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Int_Young_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Other_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Cnv_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Segdup_Fully_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Exon_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Unclassified_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Simple_Low_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Int_Young_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Other_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Cnv_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Segdup_Partially_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Exon_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Unclassified_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Simple_Low_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Int_Young_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Repeat_Other_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Cnv_No_Called_Count` bigint(20) DEFAULT NULL,
  `COVERAGE_Segdup_No_Called_Count` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assembly_files`
--

DROP TABLE IF EXISTS `assembly_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assembly_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `genome_reference_id` int(11) DEFAULT NULL,
  `assembly_id` int(11) DEFAULT NULL,
  `file_type_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `file_date` date DEFAULT NULL,
  `metadata` text,
  `disk_id` varchar(50) DEFAULT NULL,
  `software` varchar(255) DEFAULT NULL,
  `software_version` varchar(255) DEFAULT NULL,
  `record_date` date DEFAULT NULL,
  `current` tinyint(1) DEFAULT NULL,
  `comments` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audits`
--

DROP TABLE IF EXISTS `audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditable_id` int(11) DEFAULT NULL,
  `auditable_type` varchar(255) DEFAULT NULL,
  `association_id` int(11) DEFAULT NULL,
  `association_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `audited_changes` text,
  `version` int(11) DEFAULT '0',
  `comment` varchar(255) DEFAULT NULL,
  `remote_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `association_index` (`association_id`,`association_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnoses`
--

DROP TABLE IF EXISTS `diagnoses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `diagnoses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `disease_id` int(11) DEFAULT NULL,
  `age_of_onset` varchar(50) DEFAULT NULL,
  `disease_information` text,
  `output_order` int(11) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`,`disease_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diseases`
--

DROP TABLE IF EXISTS `diseases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `diseases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `omim_id` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `diseases` WRITE;
/*!40000 ALTER TABLE `diseases` DISABLE KEYS */;
INSERT INTO `diseases` VALUES (1,'Miller-Dieker Lissencencephaly Syndrome','247200','Features of the Miller-Dieker syndrome include classic lissencephaly (pachygyria, incomplete or absent gyration of the cerebrum), microcephaly, wrinkled skin over the glabella and frontal suture, prominent occiput, narrow forehead, downward slanting palpebral fissures, small nose and chin, cardiac malformations, hypoplastic male extrenal genitalia, growth retardation, and mental deficiency with seizures and EEG abnormalities. Life expectancy is grossly reduced, with death most often occurring during early childhood','2011-10-12 16:06:36','2011-10-12 16:06:36'),(2,'Adams-Oliver Syndrome 1','100300','Adams-Oliver syndrome (AOS) is characterized by the congenital absence of skin, known as aplasia cutis congenita, usually limited to the scalp vertex, and transverse limb defects. The clinical features are highly variable and can also include vascular defects, congenital cardiac malformations, and other abnormalities','2011-10-12 16:09:36','2011-10-12 16:09:36'),(3,'Adams-Oliver Syndrome 2','614219','Adams-Oliver syndrome-2 is an autosomal recessive multiple congenital anomaly syndrome that is characterized by aplasia cutis congenita and terminal transverse limb defects, in association with variable involvement of the brain, eyes, and cardiovascular systems','2011-10-12 16:10:15','2011-10-12 16:10:15'),(4,'Huntington Disease','143100','Huntington disease (HD) is an autosomal dominant progressive neurodegenerative disorder with a distinct phenotype characterized by chorea, dystonia, incoordination, cognitive decline, and behavioral difficulties. There is progressive, selective neural cell loss and atrophy in the caudate and putamen.','2011-10-12 16:12:53','2011-10-12 16:12:53'),(5,'Spinal Muscular Atrophy','','Spinal muscular atrophy refers to a group of autosomal recessive neuromuscular disorders characterized by degeneration of the anterior horn cells of the spinal cord, leading to symmetrical muscle weakness and atrophy. SMA is the second most common lethal, autosomal recessive disease in Caucasians after cystic fibrosis.  Four types of SMA are recognized depending on the age of onset, the maximum muscular activity achieved, and survivorship: type I, severe infantile acute SMA, or Werdnig-Hoffman disease; type II (253550), or infantile chronic SMA; type III (253400), juvenile SMA, or Wohlfart-Kugelberg-Welander disease; and type IV (271150), or adult-onset SMA. All types are caused by recessive mutations in the SMN1 gene.','2011-10-12 16:15:11','2011-10-12 16:15:11'),(6,'Alternating Hemiplegia of Childhood','104290','Alternating hemiplegia of childhood is a rare syndrome of episodic hemi- or quadriplegia lasting minutes to days. Most cases are accompanied by dystonic posturing, choreoathetoid movements, nystagmus, other ocular motor abnormalities, autonomic disturbances, and progressive cognitive impairment. The disorder is likely genetically heterogeneous and may mimic or overlap with other disorders, including familial hemiplegic migraine (FHM1; 141500) and GLUT1 deficiency syndrome (606777).','2011-10-12 16:16:19','2011-10-12 16:16:19'),(7,'Fanconi Anemia','','Fanconi anemia is a clinically and genetically heterogeneous disorder that causes genomic instability. Characteristic clinical features include developmental abnormalities in major organ systems, early-onset bone marrow failure, and a high predisposition to cancer. The cellular hallmark of FA is hypersensitivity to DNA crosslinking agents and high frequency of chromosomal aberrations pointing to a defect in DNA repair.  Soulier et al. (2005) noted that the FANCA, -C, -E, -F, -G, and -L proteins are part of a nuclear multiprotein core complex which triggers activating monoubiquitination of the FANCD2 protein during S phase of the growth cycle and after exposure to DNA crosslinking agents. The FA/BRCA pathway is involved in the repair of DNA damage.  Other Fanconi anemia complementation groups include FANCB (300514), caused by mutation in the FANCB (300515) on chromosome Xp22; FANCC (227645), caused by mutation in the FANCC (613899) on chromosome 9q22; FANCD1 (605724), caused by mutation in the BRCA2 (600185) on chromosome 13q12; FANCD2 (227646), caused by mutation in the FANCD2 gene (613984) on chromosome 3p25; FANCE (600901), caused by mutation in the FANCE gene (613976) on chromosome 6p22-p21; FANCF (603467), caused by mutation in the FANCF gene (613897) on chromosome 11p15; FANCG (614082), caused by mutation in the XRCC9 gene (FANCG; 602956) on chromosome 9p13; FANCI (609053), caused by mutation in the FANCI gene (611360) on chromosome 15q25-q26; FANCJ (609054), caused by mutation in the BRIP1 gene (605882) on chromosome 17q22; FANCL (614083), caused by mutation in the PHF9 gene (FANCL; 608111) on chromosome 2p16; FANCM (614087), caused by mutation in the FANCM gene (609644) on chromosome 14q21.3; FANCN (610832), caused by mutation in the PALB2 gene (610355) on chromosome 16p12; FANCO (613390), caused by mutation in the RAD51C (602774) on chromosome 17q22; and FANCP (613951), caused by mutation in the SLX4 gene (613278) on chromosome 16p13.','2011-10-12 16:19:02','2011-10-12 16:19:02'),(8,'Congenital Heart Disease','','Coronary heart disease is a complex multifactorial disorder for which several loci have been identified. CHDS1 represents a locus on chromosome 16pter-p13; CHDS2 (608316), on 2q21.1-q22; CHDS3 (300464), on Xq23-q26; CHDS4 (608318), on 14q32, and CHDS9 (612030) on 8p22. CHDS5 (608901) represents susceptibility associated with single-nucleotide polymorphism (SNP) in the KALRN gene (604605), on 3q13. CHDS6 is associated with a polymorphism in the promoter region of the MMP3 gene (185250), and CHDS7 (610938) represents susceptibility correlated with a common haplotype in the CD36 gene (173510) and high free fatty acid levels. CHDS8 (611139) is associated with SNP variation on 9p21.','2011-10-12 16:23:24','2012-05-18 21:35:15'),(9,'Epilepsy, ideopathic generalized','600669','Idiopathic generalized epilepsy is a broad term that encompasses several common seizure phenotypes, classically including childhood absence epilepsy (CAE, ECA) (600131), juvenile absence epilepsy (JAE, EJA) (607631), juvenile myoclonic epilepsy (JME, EJM) (254770), and epilepsy with grand mal seizures on awakening (Commission on Classification and Terminology of the International League Against Epilepsy, 1989). These recurrent seizures occur in the absence of detectable brain lesions and/or metabolic abnormalities. Seizures are initially generalized with a bilateral, synchronous, generalized, symmetrical EEG discharge (Zara et al., 1995; Lu and Wang, 2009).','2011-10-13 20:32:26','2011-10-13 21:35:02'),(10,'Childhood absence epilepsy','600131','Childhood absence epilepsy (CAE, ECA), a subtype of idiopathic generalized epilepsy (EIG) (600669), is characterized by a sudden and brief impairment of consciousness that is accompanied by a generalized, synchronous, bilateral, 2.5- to 4-Hz spike and slow-wave discharge (SWD) on EEG. Seizure onset occurs between 3 and 8 years of age and seizures generally occur multiple times per day. About 70% of patients experience spontaneous remission of seizures, often around adolescence. There are no structural neuropathologic findings in patients with ECA.','2011-10-13 21:06:45','2011-10-13 21:35:20'),(11,'Juvenile Myoclonic Epilepsy','254770','Juvenile myoclonic epilepsy is a subtype of idiopathic generalized epilepsy (EIG) (600669) affecting up to 26% of all individuals with EIG. Individuals with JME have afebrile seizures only, with onset in adolescence of myoclonic jerks. Myoclonic jerks occur usually in the morning','2011-10-13 21:34:27','2011-10-13 21:34:27'),(12,'Mental retardation with epilepsy','',NULL,'2012-01-17 20:03:22','2012-01-17 20:03:22'),(13,'Generalized epilepsy with febrile seizures','',NULL,'2012-01-17 22:49:09','2012-01-17 22:49:09'),(14,'abnormal EEG','',NULL,'2012-01-19 21:45:20','2012-01-19 21:45:20'),(15,'Left ventricular non-compaction (LVNC)','#604169, %609470','Left ventricular noncompaction (LVNC) is characterized by numerous prominent trabeculations and deep intertrabecular recesses in hypertrophied and hypokinetic segments of the left ventricle (Sasse-Klaassen et al., 2004). The mechanistic basis is thought to be an intrauterine arrest of myocardial development with lack of compaction of the loose myocardial meshwork. LVNC may occur in isolation or in association with congenital heart disease. Distinctive morphologic features can be recognized on 2-dimensional echocardiography (Kurosaki et al., 1999). Noncompaction of the ventricular myocardium is sometimes referred to as spongy myocardium. Stollberger et al. (2002) commented that the term \'isolated LVNC,\' meaning LVNC without coexisting cardiac abnormalities, is misleading, because additional cardiac abnormalities are found in nearly all patients with LVNC.\r\n\r\nGenetic Heterogeneity of Left Ventricular Noncompaction\r\n\r\nA locus for autosomal dominant left ventricular noncompaction has been identified on chromosome 11p15 (LVNC2; 609470).\r\n\r\nLVNC3 (see 605906) is caused by mutation in the LDB3 gene on chromosome 10q22.2-q23.3. LVNC4 (see 613424) is caused by mutation in the ACTC1 gene (102540) on chromosome 15q14. LVNC5 (see 613426) is caused by mutation in the MYH7 gene (160760) on chromosome 14q12. LVNC6 (see 601494) is caused by mutation in the TNNT2 gene (191045) on chromosome 1q32.\r\n\r\nThere is also an X-linked form of LVNC (LVNCX; 300183), caused by mutation in the TAZ gene (300394) and allelic to Barth syndrome (302060).\r\n\r\nNomenclature\r\nAlthough left ventricular noncompaction (LVNC) has been classified as a primary genetic cardiomyopathy by the American Heart Association (Maron et al., 2006), Monserrat et al. (2007) stated that it is controversial whether LVNC should be considered a distinct cardiomyopathy or rather a phenotypic variant of other primary cardiomyopathies, noting that patients fulfilling echocardiographic criteria for LVNC may have associated phenotypes of dilated cardiomyopathy (see CMD1A, 115200), hypertrophic cardiomyopathy (see CMH1, 192600), or restrictive cardiomyopathy (see RCM1, 115210). Monserrat et al. (2007) concluded that with current diagnostic criteria, LVNC, CMH, RCM, and even CMD could appear as overlapping entities, and should not be considered mutually exclusive.\r\n\r\nClinical Features\r\nKurosaki et al. (1999) described a possibly autosomal dominant form of isolated noncompaction of the left ventricular myocardium. The proband was a 58-year-old male. His parents were cousins, and both died of cerebral infarction. It was unknown whether or not they had suffered from heart disease. The proband had had recent onset of faintness and palpitation. His nose was flat and upturned, similar to a saddle nose. Electrocardiography showed first-degree atrioventricular block and complete right bundle branch block. On 2-dimensional echocardiography, the main abnormality consisted of prominent trabeculations of the left ventricular apex with deep intertrabecular spaces. Physical and electrocardiographic examinations were performed in 9 of 17 members of 3 generations of the family, and 2-dimensional and Doppler echocardiography were performed in those members who showed characteristic facial dysmorphism or electrocardiographic abnormalities. In this way, noncompaction of the left ventricular myocardium was diagnosed in 4 other members of the family. The proband\'s older brother was seen at the age of 48 years for palpitation and shortness of breath. Electrocardiography showed normal sinus rhythm with left bundle branch block, which developed into chronic atrial fibrillation in later years. Nonsustained ventricular tachycardia and sinus arrest for 7.9 seconds were detected by Holter electrocardiography. At the age of 52 and 56, he suffered small episodes of cerebral embolism. He died of progressive congestive heart failure at the age of 59 years. Autopsy showed trabeculations at the apex of the left ventricle. This man\'s son, at the age of 31, showed no facial dysmorphism, but electrocardiography showed incomplete right bundle branch block and 2-dimensional echocardiography showed systolic left ventricular dysfunction with prominent trabeculations in the apical portion. The proband\'s son, at the age of 30, showed normal left ventricular contraction with marked trabeculations at the apex and blood flow within intertrabecular spaces, on echocardiography.\r\n\r\nCytogenetics\r\nPauli et al. (1999) described a 7.5-year-old girl with a complex heart malformation including ventricular myocardial noncompaction. She was found to have a distal 5q deletion, del(5)(q35.1-q35.3). FISH showed that this deletion included the locus for the cardiac-specific homeobox gene CSX (600584). Pauli et al. (1999) interpreted the findings to suggest that in some instances ventricular myocardial noncompaction can be caused by haploinsufficiency of CSX.\r\n\r\nInheritance\r\nAutosomal dominant transmission of ventricular noncompaction was suggested by Ritter et al. (1997) and Sasse-Klaassen et al. (2003).\r\n\r\nMolecular Genetics\r\nIn affected members of a 4-generation Japanese family with left ventricular noncompaction, Ichida et al. (2001) identified a missense mutation in the DTNA gene (P121L; 601239.0001). Of the 6 individuals with LVNC, only 1 had no other congenital heart defects; the other 5 all had at least 1 ventricular septal defect, and 1 patient also had a patent ductus arteriosus, another had hypoplastic left ventricle, and another died with a hypoplastic left heart. In a second Japanese family with LVNC and congenital heart defects in which a mother and 2 daughters were affected, no mutation in alpha-dystrobrevin or in the X-linked TAZ gene (300394) was found by Ichida et al. (2001).\r\n\r\nAnimal Model\r\nIsolated noncompaction of left ventricular myocardium is observed in mice in which the FK506-binding protein 1A gene (FKBP1A; 186945) has been \'knocked out\' by embryonic stem cell technology. The FKBP1A gene maps to 20p13.\r\n\r\nREFERENCES\r\n1.       Ichida, F., Tsubata, S., Bowles, K. R., Haneda, N., Uese, K., Miyawaki, T., Dreyer, W. J., Messina, J., Li, H., Bowles, N. E., Towbin, J. A. Novel gene mutations in patients with left ventricular noncompaction or Barth syndrome. Circulation 103: 1256-1263, 2001. [PubMed: 11238270, related citations] [Full Text: HighWire Press, Pubget]\r\n\r\n2.        Kurosaki, K., Ikeda, U., Hojo, Y., Fujikawa, H., Katsuki, T., Shimada, K. Familial isolated noncompaction of the left ventricular myocardium. Cardiology 91: 69-72, 1999. [PubMed: 10393402, related citations] [Full Text: S. Karger AG, Basel, Switzerland, Pubget]\r\n\r\n3.     Maron, B. J., Towbin, J. A., Thiene, G., Antzelevitch, C., Corrado, D., Arnett, D., Moss, A. J., Seidman, C. E., Young, J. B. Contemporary definitions and classification of the cardiomyopathies: an American Heart Association scientific statement from the Council on Clinical Cardiology, Heart Failure and Transplantation Committee; Quality of Care and Outcomes Research and Functional Genomics and Translational Biology Interdisciplinary Working Groups; and Council on Epidemiology and Prevention. Circulation 113: 1807-1816, 2006. [PubMed: 16567565, related citations] [Full Text: HighWire Press, Pubget]\r\n\r\n4.     Monserrat, L., Hermida-Prieto, M., Fernandez, X., Rodriguez, I., Dumont, C., Cazon, L., Cuesta, M. G., Gonzalez-Juanatey, C., Peteiro, J., Alvarez, N., Penas-Lado, M., Castro-Beiras, A. Mutation in the alpha-cardiac actin gene associated with apical hypertrophic cardiomyopathy, left ventricular non-compaction, and septal defects. Europ. Heart J. 28: 1953-1961, 2007. [PubMed: 17611253, related citations] [Full Text: HighWire Press, Pubget]\r\n\r\n5.    Pauli, R. M., Scheib-Wixted, S., Cripe, L., Izumo, S., Sekhon, G. S. Ventricular noncompaction and distal chromosome 5q deletion. Am. J. Med. Genet. 85: 419-423, 1999. [PubMed: 10398271, related citations] [Full Text: John Wiley & Sons, Inc., Pubget]\r\n\r\n6.     Ritter, M., Oechslin, E., Sutsch, G., Attenhofer, C., Schneider, J., Jenni, R. Isolated noncompaction of the myocardium in adults. Mayo Clin. Proc. 72: 26-31, 1997. [PubMed: 9005281, related citations] [Full Text: Pubget]\r\n\r\n7.      Sasse-Klaassen, S., Gerull, B., Oechslin, E., Jenni, R., Thierfelder, L. Isolated noncompaction of the left ventricular myocardium in the adult is an autosomal dominant disorder in the majority of patients. Am. J. Med. Genet. 119A: 162-167, 2003. [PubMed: 12749056, related citations] [Full Text: John Wiley & Sons, Inc., Pubget]\r\n\r\n8.       Sasse-Klaassen, S., Probst, S., Gerull, B., Oechslin, E., Nurnberg, P., Heuser, A., Jenni, R., Hennies, H. C., Thierfelder, L. Novel gene locus for autosomal dominant left ventricular noncompaction maps to chromosome 11p15. Circulation 109: 2720-2723, 2004. [PubMed: 15173023, related citations] [Full Text: HighWire Press, Pubget]\r\n\r\n9.     Stollberger, C., Finsterer, J., Blazek, G. Left ventricular hypertrabeculation/noncompaction and association with additional cardiac abnormalities and neuromuscular disorders. Am. J. Cardiol. 90: 899-902, 2002. [PubMed: 12372586, related citations] [Full Text: Elsevier Science, Pubget]\r\n\r\nâ�¸ Contributors:  Marla J. F. O\'Neill - updated : 6/7/2010\r\nCreation Date:     Victor A. McKusick : 9/14/1999\r\nâ�¸ Edit History:         wwang : 09/28/2010','2012-01-24 23:09:24','2012-01-24 23:09:24'),(16,'Anterior Cruciate Ligament injury','',NULL,'2012-02-29 20:02:36','2012-02-29 20:02:36'),(17,'BPI','',NULL,'2012-03-27 20:19:44','2012-03-27 20:20:14'),(18,'Glioblastoma','',NULL,'2012-04-05 21:04:08','2012-04-05 21:04:08'),(19,'Alzheimers Disease','',NULL,'2012-04-11 21:33:26','2012-04-11 21:33:26'),(20,'Tetralogy of Fallot','','Tetralogy of Fallot (TOF) is a congenital heart defect which is classically understood to involve four anatomical abnormalities (although only three of them are always present). It is the most common cyanotic heart defect, and the most common cause of blue baby syndrome','2012-05-11 23:40:41','2012-05-11 23:40:41'),(21,'Pityriasis rubra pilaris','173200','This disorder is \'characterized by scaly and horny productions situated chiefly in the sebaceous follicles and by a more or less generalized hyperemia\' to use the words of DeVergie who first described it (Zeisler, 1923) in a man and his son and 2 daughters. The lesions consist \'of acuminate follicular plugging about the dorsal aspects of the hands and feet, and large plaquelike, scaling psoriasiform lesions of the extensor surfaces of the arms, legs and thighs as well as the neck and calves.\' Weiner and Levin (1943) found 39 cases in 3 generations. Beamer et al. (1972) contrasted the acquired and hereditary forms. The hereditary form tends to be less severe and more limited in extent. The hereditary form does not show skin lesions at birth, a feature that distinguishes it from ichthyosiform dermatoses.','2012-05-18 21:02:33','2012-05-18 21:02:33'),(23,'Centronuclear Myopathy','',NULL,'2012-06-12 00:41:27','2012-06-12 00:41:27'),(24,'Nemaline Myopathy','',NULL,'2012-06-12 01:07:16','2012-06-12 01:07:16'),(25,'High-Altitude Dweller','',NULL,'2012-07-09 19:58:56','2012-07-09 19:58:56'),(26,'Atlantic','',NULL,'2012-07-19 17:34:56','2012-07-19 17:34:56'),(27,'Inflammatory Bowel Disease','',NULL,'2012-09-05 21:18:13','2012-09-05 21:18:13'),(28,'Advanced Age','',NULL,'2012-10-02 18:30:11','2012-10-02 18:30:11'),(29,'Palmoplantar keratoderma','',NULL,'2012-10-02 21:14:38','2012-10-02 21:14:38'),(30,'Epilepsy, Rolandic','',NULL,'2012-10-19 18:44:03','2012-10-19 18:44:03'),(31,'Cancer','','This is a generic designation for cancers and tumors.\r\n\r\nIt is useful in screening in the pipeline.','2012-11-09 00:13:37','2012-11-09 00:13:37'),(32,'Cushing syndrome','219080',NULL,'2012-12-07 17:40:51','2012-12-07 17:40:51'),(33,'Preterm Birth',NULL,'Preterm birth has several different categories, but this indicates general affectedness.  Born prior to 38 weeks.','2013-03-20 18:58:09','2013-03-20 18:58:09'),(34,'Epilepsy, autosomal recessive',NULL,NULL,'2013-03-21 00:08:13','2013-03-21 00:08:13'),(35,'Supercentenarian',NULL,'more than 110 years of age','2013-07-10 17:08:24','2013-07-10 17:08:24'),(36,'Centenarian',NULL,'more than 100 years of age','2013-07-10 17:08:47','2013-07-10 17:08:47'),(37,'Balint\'s syndrome',NULL,'from Wikipedia:\r\nBálint\'s syndrome is an uncommon and incompletely understood triad of severe neuropsychological impairments: inability to perceive the visual field as a whole (simultanagnosia), difficulty in fixating the eyes (oculomotor apraxia), and inability to move the hand to a specific object by using vision (optic ataxia).[1] It was named in 1909 for the Austro-Hungarian neurologist Rezs? Bálint who first identified it.[2][3]\r\n\r\nBálint\'s syndrome occurs most often with an acute onset as a consequence of two or more strokes at more or less the same place in each hemisphere. Therefore, it occurs rarely. The most frequent cause of complete Bálint\'s syndrome is said by some to be sudden and severe hypotension, resulting in bilateral borderzone infarction in the occipito-parietal region.[1] More rarely, cases of progressive Bálint\'s syndrome have been found in degenerative disorders such as Alzheimer\'s disease[4][5] or certain other traumatic brain injuries at the border of the parietal and the occipital lobes of the brain.\r\n\r\nLack of awareness of this syndrome may lead to a misdiagnosis and resulting inappropriate or inadequate treatment. Therefore, clinicians should be familiar with Bálint\'s syndrome and its various etiologies.[6]','2013-09-05 22:47:10','2013-09-05 22:47:10'),(38,'Diabetes',NULL,NULL,'2013-10-07 19:27:28','2013-10-07 19:27:28');
/*!40000 ALTER TABLE `diseases` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `file_types`
--

DROP TABLE IF EXISTS `file_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `file_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(50) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_types`
--

LOCK TABLES `file_types` WRITE;
/*!40000 ALTER TABLE `file_types` DISABLE KEYS */;
INSERT INTO `file_types` VALUES (1,'VAR-ANNOTATION',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(2,'GENE-ANNOTATION',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(3,'GENE-VAR-SUMMARY-REPORT',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(4,'NCRNA-ANNOTATION',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(5,'CNV-SEGMENTS',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(6,'JUNCTIONS',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(7,'SUMMARY',NULL,'2011-11-01 14:50:26','2011-11-01 14:50:29'),(8,'VCF-SNP-ANNOTATION',NULL,'2012-03-13 14:01:48','2012-03-13 14:01:48'),(9,'VCF-INDEL-ANNOTATION',NULL,'2012-03-13 14:01:56','2012-03-13 14:01:56'),(10,'SVEVENTS',NULL,'2012-06-28 15:41:49','2012-06-28 15:41:49'),(11,'VAR-OLPL',NULL,NULL,NULL);
/*!40000 ALTER TABLE `file_types` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `genome_references`
--

DROP TABLE IF EXISTS `genome_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genome_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `build_name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genome_references`
--

LOCK TABLES `genome_references` WRITE;
/*!40000 ALTER TABLE `genome_references` DISABLE KEYS */;
INSERT INTO `genome_references` VALUES (1,'hg19','NCBI build 37',NULL,NULL,NULL,'2011-08-31 21:19:02','2011-08-31 21:19:02'),(2,'hg18','NCBI build 36',NULL,NULL,NULL,'2011-08-31 21:19:02','2011-08-31 21:19:02');
/*!40000 ALTER TABLE `genome_references` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `memberships`
--

DROP TABLE IF EXISTS `memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pedigree_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `draw_duplicate` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pedigree_id` (`pedigree_id`,`person_id`),
  KEY `membership_person` (`person_id`),
  KEY `membership_pedigree` (`pedigree_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedigrees`
--

DROP TABLE IF EXISTS `pedigrees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedigrees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isb_pedigree_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  `study_id` int(11) DEFAULT NULL,
  `directory` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `genotype_vector_date` datetime DEFAULT NULL,
  `quartet_date` datetime DEFAULT NULL,
  `autozygosity_date` datetime DEFAULT NULL,
  `relation_pairing_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_pedigrees_on_name_and_tag` (`name`,`tag`),
  KEY `pedigrees_isb_pedigree_id` (`isb_pedigree_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isb_person_id` varchar(255) DEFAULT NULL,
  `collaborator_id` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `dod` date DEFAULT NULL,
  `deceased` tinyint(1) NOT NULL DEFAULT '0',
  `planning_on_sequencing` tinyint(1) DEFAULT '0',
  `complete` tinyint(1) DEFAULT NULL,
  `root` tinyint(1) DEFAULT NULL,
  `comments` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pedigree_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_people_on_isb_person_id` (`isb_person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_aliases`
--

DROP TABLE IF EXISTS `person_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `alias_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `alias_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phenotypes`
--

DROP TABLE IF EXISTS `phenotypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phenotypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `disease_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  `phenotype_type` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Dumping data for table `phenotypes`
--

LOCK TABLES `phenotypes` WRITE;
/*!40000 ALTER TABLE `phenotypes` DISABLE KEYS */;
INSERT INTO `phenotypes` VALUES (2,2,'Cutis marmorata telangiectatica congenita',NULL,NULL,'Cutis marmorata telangiectatica congenita or CMTC is a rare congenital vascular disorder that usually manifests in affecting the blood vessels of the skin. The condition was first recognised and described in 1922 by Cato van Lohuizen, a Dutch pediatrician whose name was later adopted in the other common name used to describe the condition - Van Lohuizen Syndrome. CMTC is also used synonymously with congenital generalized phlebectasia, nevus vascularis reticularis, congenital phlebectasia, livedo telangiectatica, congenital livedo reticularis and Van Lohuizen syndrome.','2011-08-31 21:19:03','2011-10-14 00:58:12'),(3,2,'Aplasia cutis congenita',NULL,NULL,'Aplasia cutis congenita (also known as \"Cutis aplasia,\" \"Congenital absence of skin,\" and \"Congenital scars\") is the most common congenital cicatricial alopecia, and is a congenital focal absence of epidermis with or without evidence of other layers of the skin.','2011-08-31 21:19:03','2011-10-13 20:50:39'),(4,2,'Terminal Transverse Limb Defects',NULL,NULL,'Malformation of the limbs.  The term \"terminal transverse\" was used for absence or hypoplasia of digits 1 to 5, 2 to 5, or 1 to 4.','2011-08-31 21:19:03','2011-10-13 20:54:06'),(6,NULL,'GATA4 required_surgery',NULL,NULL,NULL,'2011-08-31 21:19:03','2011-11-11 18:05:54'),(7,NULL,'GATA4 mutation',NULL,NULL,NULL,'2011-08-31 21:19:03','2011-08-31 21:19:03'),(8,NULL,'Ventricular Septal Defect',NULL,NULL,'Ventricular septal defect describes one or more holes in the wall that separates the right and left ventricles of the heart. Ventricular septal defect is one of the most common congenital (present from birth) heart defects. It may occur by itself or with other congenital diseases.','2011-08-31 21:19:03','2011-10-13 20:54:51'),(9,NULL,'Pulmonary Stenosis',NULL,NULL,'The word \"pulmonary\" denotes \"to do with the lungs\". The pulmonary valve is located between the right ventricle and the pulmonary artery. It regulates blood flow into the lungs, and prevents blood from leaking back into the right ventricle.  Sometimes, this pulmonary valve is extremely narrow, and blocks the smooth flow of blood into the lungs. This condition is called Pulmonary Stenosis - or PS, in short. At other times, the pulmonary valve itself is normal, but there is an obstruction to blood flow from the right ventricle at other levels. For instance, there may be abnormal bundles of muscle below the pulmonary valve which obstruct flow. This is called \"sub-valvular\" pulmonary stenosis. Or occassionally, there may be a narrowing of the pulmonary artery or its branches above the pulmonary valve. This is called \"supra-valvular\" pulmonary stenosis. ','2011-08-31 21:19:03','2011-10-13 20:56:06'),(10,NULL,'Patent ductus arteriosus',NULL,NULL,'Patent ductus arteriosus (PDA) is a congenital disorder in the heart wherein a neonate\'s ductus arteriosus fails to close after birth. Early symptoms are uncommon, but in the first year of life include increased work of breathing and poor weight gain. With age, the PDA may lead to congestive heart failure if left uncorrected.','2011-08-31 21:19:03','2011-10-13 20:56:40'),(11,NULL,'Cardiomyopathy',NULL,NULL,'Cardiomyopathy refers to diseases of the heart muscle. These diseases have many causes, signs and symptoms, and treatments.  In cardiomyopathy, the heart muscle becomes enlarged, thick, or rigid. In rare cases, the muscle tissue in the heart is replaced with scar tissue.  As cardiomyopathy worsens, the heart becomes weaker. It\'s less able to pump blood through the body and maintain a normal electrical rhythm. This can lead to heart failure or irregular heartbeats called arrhythmias. In turn, heart failure can cause fluid to build up in the lungs, ankles, feet, legs, or abdomen.','2011-08-31 21:19:04','2011-10-13 20:57:31'),(12,NULL,'Atrioventricular septal defect',NULL,NULL,'Antrioventricular septal defects is characterised by a deficiency of the atrioventricular septum of the heart. AVSD is caused by an abnormal or inadequate fusion of the superior and inferior endocardial cushions with the mid portion of the atrial septum and the muscular portion of the ventricular septum','2011-08-31 21:19:04','2011-10-13 21:00:02'),(25,NULL,'MKK: Maasai in Kinyawa, Kenya',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(27,NULL,'CHB: Han Chinese in Beijing, China',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(29,NULL,'YRI: Yorubia in Ibadan, Nigeria',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(31,NULL,'LWK: Luhya in Webuye',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(32,NULL,'ASW: African ancestry in Southwest USA',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(38,NULL,'MXL: Mexican ancestry in Los Angeles, California, USA',NULL,'ethnicity',NULL,'2011-08-31 21:19:07','2011-08-31 21:19:07'),(40,NULL,'GIH: Gujarati Indian in Houston, Texas, USA',NULL,'ethnicity',NULL,'2011-08-31 21:19:08','2011-08-31 21:19:08'),(43,NULL,'JPT: Japanese in Tokyo, Japan',NULL,'ethnicity',NULL,'2011-08-31 21:19:08','2011-08-31 21:19:08'),(45,NULL,'TSI: Toscans in Italy',NULL,'ethnicity',NULL,'2011-08-31 21:19:08','2011-08-31 21:19:08'),(48,NULL,'CEU: Utah residents with Northern and Western European from the CEPH collection',NULL,'ethnicity',NULL,'2011-08-31 21:19:08','2011-08-31 21:19:08'),(60,NULL,'YRI_TRIO: Yorubia in Ibadan, Nigeria',NULL,'ethnicity',NULL,'2011-08-31 21:19:09','2011-08-31 21:19:09'),(77,NULL,'PUR_trio: Puerto Rican in Rico',NULL,'ethnicity',NULL,'2011-08-31 21:19:11','2011-08-31 21:19:11'),(88,9,'Absence seizure',NULL,NULL,'Absence seizures are one of several kinds of seizures. These seizures are sometimes referred to as petit mal seizures (from the French for \"little illness\", a term dating from the late 18th century. Absences seizures are brief (usually less than 20 seconds), generalized epileptic seizures of sudden onset and termination. They have 2 essential components: clinically the impairment of consciousness (absence), EEG generalized spike-and-slow wave discharges.','2011-10-13 20:33:29','2011-10-13 20:33:29'),(89,9,'Eyelid Myoclonia',NULL,NULL,'Eyelid myoclonia occurs mainly during the first second of the EEG discharge and consists of repetitive, often rhythmic, fast (4 to 6 Hz), small- or large-range myoclonic jerks of the eyelids. The eyelid jerks vary in force, amplitude, and numbers even for the same patient. In each seizure, there are more than three repetitive eyelid jerks.','2011-10-13 20:35:16','2011-10-13 20:35:16'),(91,9,'generalized tonic-clonic seizures (GTCS)',NULL,NULL,'A convulsion; newer term for grand mal or major motor seizure; characterized by loss of consciousness, falling, stiffening, and jerking; electrical discharge involves all or most of the brain.','2011-10-13 21:27:00','2011-10-14 01:29:43'),(92,NULL,'Premature birth',NULL,NULL,'Premature birth, commonly used as a synonym for preterm birth, refers to the birth of a baby before the developing organs are mature enough to allow normal postnatal survival. Premature infants are at greater risk for short and long term complications, including disabilities and impediments in growth and mental development.','2011-10-13 21:30:17','2011-10-13 21:30:17'),(93,11,'Afebrile Seizure',NULL,NULL,'Afebrile seizures are seizures not caused by a high temperature. A child having an afebrile seizure will make jerky movements for a few seconds to a few minutes, and then become drowsy. Itâ€™s normal for a child to be drowsy for a while afterwards. ','2011-10-13 21:36:21','2011-10-13 21:36:21'),(94,11,'Myoclonic jerks',NULL,NULL,'Myoclonus is brief, involuntary twitching of a muscle or a group of muscles.  Myoclonic jerks may occur alone or in sequence, in a pattern or without pattern.  Seizures usually involve the neck, shoulders, and upper arms. These seizures typically occur shortly after waking up. They normally begin between puberty and early adulthood.','2011-10-13 21:38:51','2011-10-13 21:38:51'),(95,9,'Epilepsy with Grand Mal Seizures on Awakening (EGMA)',NULL,NULL,'Generalized tonic-clonic seizures occur exclusively or predominantly shortly after awakening. The onset is usually in the second decade. If patients have other seizure types, they are usually absence or myoclonic seizures. Photosensitivity is a common feature.','2011-10-14 01:07:58','2012-01-23 20:48:40'),(96,9,'Febrile Seizure (FS)',NULL,NULL,'Children aged 3 months to 5 years may have tonic-clonic seizures when they have a high fever. These are called febrile seizures (usually pronounced FEB-rile) and occur in 2% to 5% of all children. There is a slight tendency for them to run in families. If a child\'s parents, brothers or sisters, or other close relatives have had febrile seizures, the child is a bit more likely to have them. ','2011-10-14 01:29:18','2011-10-14 01:29:18'),(97,9,'Complex partial seizure (CPS)',NULL,NULL,'A complex partial seizure is an epileptic seizure that is associated with bilateral cerebral hemisphere involvement and causes impairment of awareness or responsiveness, i.e. loss of consciousness.','2011-10-14 01:51:20','2011-10-14 01:51:20'),(98,6,'AHC Balanced Translocation Chr3 and Chr9',NULL,NULL,'Balanced translocation involving chromosome 3 and chromosome 9','2011-11-18 22:04:55','2011-11-18 22:04:55'),(99,6,'Copy Number Variation chr13',NULL,NULL,'Copy number variation in chr13.  Identified by CGI.','2011-11-18 22:05:32','2011-11-18 22:05:32'),(100,NULL,'Behavioral problems',NULL,NULL,NULL,'2012-01-13 20:42:18','2012-01-13 20:42:18'),(101,NULL,'Developmental delay',NULL,NULL,NULL,'2012-01-13 20:46:06','2012-01-13 20:46:06'),(102,NULL,'Mild mental retardation',NULL,NULL,NULL,'2012-01-13 20:48:37','2012-01-13 20:48:37'),(103,NULL,'Learning disability',NULL,NULL,NULL,'2012-01-13 20:50:25','2012-01-13 20:50:25'),(104,8,'Atrial Septal Defect (ASD)',NULL,NULL,'Atrial Septal Defect (ASD)','2012-01-16 22:06:30','2012-01-16 22:06:30'),(105,9,'Childhood absence epilepsy (CAE)',NULL,NULL,NULL,'2012-01-23 20:38:00','2012-01-23 20:51:13'),(106,9,'Juvenile absence epilepsy (JAE)',NULL,NULL,NULL,'2012-01-23 20:43:42','2012-01-23 20:51:29'),(107,9,'Juvenile myoclonic epilepsy (JME)',NULL,NULL,NULL,'2012-01-23 20:49:54','2012-01-23 20:49:54'),(108,4,'Huntington\'s Disease CAG Repeat Numbers',NULL,NULL,'The counts of the CAG repeats in the two alleles of the Huntingtin gene.','2012-01-27 20:18:50','2012-01-27 20:18:50'),(109,16,'Anterior cruciate ligament tear',NULL,NULL,'Anterior cruciate ligament tear','2012-03-08 19:52:45','2012-06-22 23:35:11'),(110,16,'Bilateral ACL tear',NULL,NULL,'Bilateral ACL tear','2012-03-08 19:53:07','2012-06-22 23:37:34'),(111,16,'Meniscus tear',NULL,NULL,'Meniscus tear','2012-03-08 19:53:25','2012-06-22 23:37:43'),(112,16,'Bilateral meniscus tear',NULL,NULL,'Bilateral meniscus tear','2012-03-08 19:53:52','2012-06-22 23:37:52'),(113,16,'Medial collateral ligament sprain',NULL,NULL,'Medial collateral ligament sprain','2012-03-08 19:54:20','2012-06-22 23:38:01'),(114,NULL,'breast cancer',NULL,NULL,'breast cancer','2012-03-08 19:54:34','2012-06-22 23:38:12'),(115,NULL,'tuberculosis',NULL,NULL,'tuberculosis','2012-03-08 19:54:49','2012-06-22 23:38:26'),(116,16,'Emphysema',NULL,NULL,'Emphysema','2012-03-08 19:55:06','2012-06-22 23:38:35'),(117,16,'ACL tear twice (same knee)',NULL,NULL,'ACL tear twice (same knee)','2012-03-08 19:56:04','2012-06-22 23:38:57'),(118,NULL,'At risk',NULL,NULL,NULL,'2012-05-18 21:38:21','2012-05-18 21:38:21'),(119,4,'Hand tremors',NULL,NULL,NULL,'2012-06-06 22:17:50','2012-06-06 22:17:50'),(120,NULL,'High-Altitude Dweller (HAD)',NULL,NULL,NULL,'2012-07-09 19:23:20','2012-07-09 19:23:20'),(121,19,'ApoE status',NULL,NULL,NULL,'2012-07-13 16:43:40','2012-07-13 16:43:40'),(122,NULL,'Hydrocephalus',NULL,NULL,NULL,'2012-09-25 21:16:37','2012-09-25 21:16:37'),(123,NULL,'Cardiac defect',NULL,NULL,NULL,'2012-09-26 16:21:43','2012-09-26 16:21:43'),(124,NULL,'CNS calcifications',NULL,NULL,NULL,'2012-09-27 16:59:52','2012-09-27 16:59:52'),(125,NULL,'gut ischemia',NULL,NULL,NULL,'2012-09-27 17:02:09','2012-09-27 17:02:09'),(126,NULL,'Portal hypertension',NULL,NULL,NULL,'2012-09-27 18:49:29','2012-09-27 18:49:29'),(127,NULL,'Multiple clots',NULL,NULL,NULL,'2012-09-27 18:50:31','2012-09-27 18:50:31'),(128,NULL,'Bladder extrophy',NULL,NULL,NULL,'2012-09-27 19:40:16','2012-09-27 19:40:16'),(129,2,'Short toes',NULL,NULL,NULL,'2012-09-27 19:46:21','2012-09-27 19:46:21'),(130,NULL,'Syndactyly',NULL,NULL,'Syndactyly (from Greek ÏƒÏ…Î½- = \"together\" plus Î´Î±ÎºÏ„Ï…Î»Î¿Ï‚ = \"finger\") is a condition wherein two or more digits are fused together.','2012-09-28 22:09:25','2012-09-28 22:09:25'),(131,NULL,'Vascular instability',NULL,NULL,NULL,'2012-09-28 22:11:26','2012-09-28 22:11:26'),(132,NULL,'Prominent scalp veins',NULL,NULL,NULL,'2012-10-02 20:15:44','2012-10-02 20:15:44'),(133,NULL,'White matter intensities',NULL,NULL,'multiple high signal  intensities  in the periventricular white matter and grey/white junction on MRI','2012-10-02 20:18:39','2012-10-02 20:18:39'),(134,NULL,'Muscle weakness',NULL,NULL,NULL,'2012-10-02 20:25:40','2012-10-02 20:25:40'),(135,30,'EEG feature only',NULL,NULL,NULL,'2012-10-19 19:07:07','2012-10-19 19:07:07'),(136,19,'Age-of-Onset of Mild Cognitive Impairment','ageMCI',NULL,'Mild cognitive impairment (MCI) represents a transitional state between the cognitive changes of normal aging and very early dementia. Measured in years of age.','2012-10-25 18:55:01','2012-10-25 18:55:01'),(137,19,'Age-of-Onset of Alzheimers Disease','ageDementia',NULL,'Also referred to as AAO in Lalli et al., (2012). This variable describes age in years of definitive diagnosis of Alzheimers Disease.','2012-10-26 18:01:30','2012-10-26 18:01:30'),(138,NULL,'Pulmonary Hypertension','Pulmonary Hypertension',NULL,NULL,'2012-12-15 00:01:03','2012-12-15 00:01:03'),(139,NULL,'Short Fingers','Short Fingers',NULL,NULL,'2012-12-15 00:37:23','2012-12-15 00:37:23'),(140,13,'Febrile Seizures (FS)','febrile seizures',NULL,NULL,'2013-06-24 19:43:34','2013-06-24 19:43:34'),(141,NULL,'Unclassified seizures','unclassified seizures',NULL,NULL,'2013-06-24 19:44:05','2013-06-24 20:06:42'),(142,NULL,'Obligate carrier','obligate carrier',NULL,NULL,'2013-06-24 19:45:11','2013-06-24 19:45:11'),(143,NULL,'Epilepsy screening panel negative','epilepsy screening panel negative',NULL,'as per Holger Lerche\'s notation','2013-08-14 19:27:36','2013-08-14 19:27:36');
/*!40000 ALTER TABLE `phenotypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relationships`
--

DROP TABLE IF EXISTS `relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `relation_id` int(11) DEFAULT NULL,
  `relationship_type` varchar(255) DEFAULT NULL,
  `relation_order` int(11) DEFAULT NULL,
  `divorced` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`,`relation_id`,`relationship_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `report_types`
--

DROP TABLE IF EXISTS `report_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_types`
--

LOCK TABLES `report_types` WRITE;
/*!40000 ALTER TABLE `report_types` DISABLE KEYS */;
INSERT INTO `report_types` VALUES (1,'Receiving');
/*!40000 ALTER TABLE `report_types` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `report_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,'ReceivingReport',NULL,1,'2011-09-26 11:36:47','2011-09-26 11:36:47');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `sample_assays`
--

DROP TABLE IF EXISTS `sample_assays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_assays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `assay_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`,`assay_id`),
  KEY `sample_assays_sample` (`sample_id`),
  KEY `sample_assays_assay` (`assay_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_types`
--

DROP TABLE IF EXISTS `sample_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `tissue` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_types`
--

LOCK TABLES `sample_types` WRITE;
/*!40000 ALTER TABLE `sample_types` DISABLE KEYS */;
INSERT INTO `sample_types` VALUES (1,'saliva',NULL,NULL,'2011-08-31 21:19:03','2011-08-31 21:19:03'),(2,'blood',NULL,NULL,'2011-08-31 21:19:03','2011-08-31 21:19:03'),(3,'skin',NULL,NULL,'2011-08-31 21:19:03','2011-08-31 21:19:03'),(4,'cell line',NULL,NULL,'2011-08-31 21:19:09','2011-08-31 21:19:09'),(5,'lymphoblasts',NULL,NULL,'2011-09-21 16:52:27','2011-09-21 16:52:32'),(6,'tissue',NULL,NULL,'2011-09-21 16:54:57','2011-09-21 16:54:57'),(7,'tumor',NULL,NULL,'2011-09-21 17:14:22','2011-09-21 17:14:22'),(8,'unknown',NULL,NULL,'2012-07-19 10:56:57','2012-07-19 10:56:57');
/*!40000 ALTER TABLE `sample_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `samples`
--

DROP TABLE IF EXISTS `samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isb_sample_id` varchar(255) DEFAULT NULL,
  `customer_sample_id` varchar(255) DEFAULT NULL,
  `sample_type_id` int(11) DEFAULT NULL,
  `sample_vendor_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `date_submitted` date DEFAULT NULL,
  `protocol` varchar(255) DEFAULT NULL,
  `volume` varchar(25) DEFAULT NULL,
  `concentration` varchar(25) DEFAULT NULL,
  `quantity` varchar(25) DEFAULT NULL,
  `date_received` date DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pedigree_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `samples_isb_sample_id` (`isb_sample_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `studies`
--

DROP TABLE IF EXISTS `studies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `studies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `tag` varchar(50) DEFAULT NULL,
  `lead` varchar(255) DEFAULT NULL,
  `collaborator` varchar(255) DEFAULT NULL,
  `collaborating_institution` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temp_objects`
--

DROP TABLE IF EXISTS `temp_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trans_id` int(11) DEFAULT NULL,
  `object_type` varchar(255) DEFAULT NULL,
  `object` blob,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `traits`
--

DROP TABLE IF EXISTS `traits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `traits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `phenotype_id` int(11) DEFAULT NULL,
  `trait_information` varchar(255) DEFAULT NULL,
  `output_order` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`,`phenotype_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-11-11 16:11:01
