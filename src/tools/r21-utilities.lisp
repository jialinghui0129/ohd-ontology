;;****************************************************************
;; Required components on user's system:
;;
;; 1. Must have an instanct of the Eaglesoft datbase and necessary drivers (see below)
;;    installed on your machine.
;; 2. A file named .pattersondbpw (containing the password of Eaglesoft database) located in
;;    your home directory.

;; Instructions for being able to connect to Eaglesoft database
;;
;; Needs "/Applications/SQLAnywhere12/System/lib32"
;;  added to DYLD_LIBRARY_PATH so it can find libdbjdbc12.jnilib and dependencies.
;; for now add (setenv "DYLD_LIBRARY_PATH" (concatenate 'string (getenv "DYLD_LIBRARY_PATH") 
;; ":/Applications/SQLAnywhere12/System/lib32")) to your .emacs
;; (#"load" 'System "/Applications/SQLAnywhere12/System/lib32/libdbjdbc12.jnilib")  
;; fails there is no easy way to update DYLD_LIBRARY_PATH within a running java instance. POS.
;;
;; The conection string for connecting to the database is retrieved by calling 
;; (get-eaglesoft-database-url).
;;****************************************************************

;;;; ensure that sql libary is loaded ;;;;
(add-to-classpath "/Applications/SQLAnywhere12/System/java/sajdbc4.jar")

;;****************************************************************
;;; general shared functions ;;;;

;; Assuming that FMA uses the same numbering system, here's how the vector is computed
;; (loop with alist 
;;    for (rel tooth) in (get FMA::|Secondary dentition| :slots)
;;    nwhen (eq rel fma::|member|)
;;    do 
;;     (let ((syns (remove-if-not (lambda(e) (eq (car e) fma::|Synonym|)) (get tooth :slots))))
;;        (loop for (rel syn) in syns
;; 	  for name = (second (find fma::|name| (get syn :slots) :key 'car))
;; 	  for number = (caar (all-matches name ".*?(\\d+).*" 1))
;; 	  when number do (push (cons (parse-integer number) tooth) alist)))
;;    finally (return (coerce 
;; 		    (mapcar (lambda(e) (cons (fma-uri e) (string e)))
;; 			    (mapcar 'cdr (sort alist '< :key 'car))) 'vector)))


(defun number-to-fma-tooth (number &key return-tooth-uri return-tooth-name return-tooth-with-number)
  "Translates a tooth number into corresponding fma class.  By default, a cons is returned consisting of the (fma-class . name).  The :return-tooth-uri key specifies that only the uri is returned.  The :return-tooth-name key specifies that only the name is returned."
  (let ((teeth nil)
	(tooth nil))
    (setf teeth
	  #((!obo:FMA_55696 "Right upper third secondary molar tooth" "tooth 1") 
	    (!obo:FMA_55697 "Right upper second secondary molar tooth" "tooth 2")
	    (!obo:FMA_55698 "Right upper first secondary molar tooth" "tooth 3")
	    (!obo:FMA_55689 "Right upper second secondary premolar tooth" "tooth 4")
	    (!obo:FMA_55689 "Right upper first secondary premolar tooth" "tooth 5")
	    (!obo:FMA_55798 "Right upper secondary canine tooth" "tooth 6")
	    (!obo:FMA_55680 "Right upper lateral secondary incisor tooth" "tooth 7")
	    (!obo:FMA_55681 "Right upper central secondary incisor tooth" "tooth 8")
	    (!obo:FMA_55682 "Left upper central secondary incisor tooth" "tooth 9")
	    (!obo:FMA_55683 "Left upper lateral secondary incisor tooth" "tooth 10")
	    (!obo:FMA_55799 "Left upper secondary canine tooth" "tooth 11")
	    (!obo:FMA_55690 "Left upper first secondary premolar tooth" "tooth 12")
	    (!obo:FMA_55691 "Left upper second secondary premolar tooth" "tooth 13")
	    (!obo:FMA_55699 "Left upper first secondary molar tooth" "tooth 14")
	    (!obo:FMA_55700 "Left upper second secondary molar tooth" "tooth 15")
	    (!obo:FMA_55701 "Left upper third secondary molar tooth" "tooth 16")
	    (!obo:FMA_55702 "Left lower third secondary molar tooth" "tooth 17")
	    (!obo:FMA_55703 "Left lower second secondary molar tooth" "tooth 18")
	    (!obo:FMA_55704 "Left lower first secondary molar tooth" "tooth 19")
	    (!obo:FMA_55692 "Left lower second secondary premolar tooth" "tooth 20")
	    (!obo:FMA_55693 "Left lower first secondary premolar tooth" "tooth 21")
	    (!obo:FMA_55687 "Left lower secondary canine tooth" "tooth 22")
	    (!obo:FMA_57141 "Left lower lateral secondary incisor tooth" "tooth 23")
	    (!obo:FMA_57143 "Left lower central secondary incisor tooth" "tooth 24")
	    (!obo:FMA_57142 "Right lower central secondary incisor tooth" "tooth 25")
	    (!obo:FMA_57140 "Right lower lateral secondary incisor tooth" "tooth 26")
	    (!obo:FMA_55686 "Right lower secondary canine tooth" "tooth 27")
	    (!obo:FMA_55694 "Right lower first secondary premolar tooth" "tooth 28")
	    (!obo:FMA_55695 "Right lower second secondary premolar tooth" "tooth 29")
	    (!obo:FMA_55705 "Right lower first secondary molar tooth" "tooth 30")
	    (!obo:FMA_55706 "Right lower second secondary molar tooth" "tooth 31")
	    (!obo:FMA_55707 "Right lower third secondary molar tooth" "tooth 32")))

    (cond
      (return-tooth-uri (setf tooth (first (aref teeth (1- number)))))
      (return-tooth-name (setf tooth (second (aref teeth (1- number)))))
      (return-tooth-with-number (setf tooth (third (aref teeth (1- number)))))
      (t (setf tooth (aref teeth (1- number)))))
    ;; return tooth uri/name
    tooth))

(defun get-fma-surface-uri (surface-name)
  "Return the uri for a tooth surface, based on the FMA ontology, for a given surface name."
  (let ((uri nil))
    (cond
      ((equalp surface-name "buccal") (setf uri !obo:FMA_no_fmaid_Buccal_surface_enamel_of_tooth))
      ((equalp surface-name "distal") (setf uri !obo:FMA_no_fmaid_Distal_surface_enamel_of_tooth))
      ((equalp surface-name "incisal") (setf uri !obo:FMA_no_fmaid_Incisal_surface_enamel_of_tooth))
      ((equalp surface-name "labial") (setf uri !obo:FMA_no_fmaid_Labial_surface_enamel_of_tooth))
      ((equalp surface-name "lingual") (setf uri !obo:FMA_no_fmaid_Lingual_surface_enamel_of_tooth))
      ((equalp surface-name "mesial") (setf uri !obo:FMA_no_fmaid_Mesial_surface_enamel_of_tooth))
      ((equalp surface-name "occlusial") (setf uri !obo:FMA_no_fmaid_Occlusial_surface_enamel_of_tooth)))

    ;; return suface uri
    uri))

(defun get-surface-name-from-surface-letter (surface-letter)
  "Returns the name of the tooth surface associated with a letter (e.g 'b' -> 'buccal')."
  (let ((surface-name nil))
    ;; remove any leading and trailing spaces from letter
    (setf surface-letter (string-trim " " surface-letter))

    (cond
      ((equalp surface-letter "b") (setf surface-name "buccal"))
      ((equalp surface-letter "d") (setf surface-name "distal"))
      ((equalp surface-letter "i") (setf surface-name "incisal"))
      ((equalp surface-letter "f") (setf surface-name "labial"))
      ((equalp surface-letter "l") (setf surface-name "lingual"))
      ((equalp surface-letter "m") (setf surface-name "mesial"))
      ((equalp surface-letter "o") (setf surface-name "occlusial")))

    ;; return surface name
    surface-name))

;; alanr
;; billd: this was intended to read data that has tooth ranges of the form "3-6".
;; however, we are reading the tooth_data array, which is processed using get-teeth-list
(defun parse-teeth-list (teeth-description)
  "Parses the tooth list format '-' is range, ',' separates, into a list of teeth numbers"
  (let ((teeth-list nil))

    (let ((pieces (split-at-char teeth-description #\,)))
      (loop for piece in pieces do
	   (cond ((find #\- piece) 
		  (destructuring-bind (start end) 
		      (mapcar 'parse-integer 
			      (car (all-matches piece "^(\\d+)-(\\d+)" 1 2)))
		    (loop for i from start to end do (push i teeth-list))))
		 ;; otherwise it is a single number
		 (t (push (parse-integer piece) teeth-list)))))
    ;; return list of teeth
    teeth-list))


(defun get-unique-individual-iri(string &key salt class-type iri-base args)
  "Returns a unique iri for individuals in the ontology by doing a md5 checksum on the string parameter. An optional md5 salt value is specified by the salt key value (i.e., :salt salt). The class-type argument (i.e., :class-type class-type) concatentates the class type to the string.  This parameter is highly suggested, since it helps guarntee that iri will be unique.  The iri-base (i.e., :iri-base iri-base) is prepended to the iri.  For example, (get-unique-iri \"test\" :iri-base \"http://test.com/\" will prepend \"http://test.com/\" to the md5 checksum of \"test\".  The args parmameter is used to specify an other information you wish to concatenate to the string paramenter.  Args can be either a single value or list; e.g., (get-unique-iri \"test\" :args \"foo\") (get-unique-iri \"test\" :args '(\"foo\" \"bar\")."
  ;; check that string param is a string
  (if (not (stringp string)) 
      (setf string (format nil "~a" string)))

  ;; prepend class type to string
  (when class-type
    (setf class-type (remove-leading-! class-type))
    (setf string (format nil "~a~a" class-type string)))
  
  ;; concatenate extra arguments to string
  (when args
    (cond 
      ((listp args)
       (loop for item in args do
	    (setf item (remove-leading-! item))
	    (setf string (format nil "~a~a" string item))))
      (t (setf string (format nil "~a~a" string args)))))

  ;; encode string
  (setf string (encode string :salt salt))
  (when iri-base
    (setf string (format nil "~aI_~a" iri-base string)))
  (make-uri string))

(defun remove-leading-! (iri)
  "Removes the leading '!' from a iri and returns the iri as a string.
If no leading '!' is present, the iri is simply returned as string."
  (setf iri (format nil "~a" iri))
  (when (equal "!" (subseq iri 0 1)) (setf iri (subseq iri 1)))
  ;; return iri
  iri)

(defun encode (string &key salt)
  "Returns and md5 checksum of the string argument.  When the salt argument is present, it used in the computing of the md5 check sum."
  (let ((it nil))
    ;; check for salt
    (when salt
      (setf string (format nil "~a~a" salt string)))
    
    (setf it (new 'com.hp.hpl.jena.shared.uuid.MD5 string))
    
    (#"processString" it)
    (#"getStringDigest" it)))

(defun str+ (&rest values)
  "A shortcut for concatenting a list of strings. Code found at:
http://stackoverflow.com/questions/5457346/lisp-function-to-concatenate-a-list-of-strings
Parameters:
  values:  The string to be concatenated.
Usage:
  (str+ \"string1\"   \"string1\" \"string 3\" ...)
  (str+ s1 s2 s3 ...)"

  ;; the following make use of the format functions
  ;;(format nil "~{~a~}" values)
  ;;; use (format nil "~{~a^ ~}" values) to concatenate with spaces
  ;; this may be the simplist to understand...
  (apply #'concatenate 'string values))

(defun str-right (string num)
  "Returns num characters from the right of string. E.g. (str-right \"test\" 2) => \"st\""
  (let ((end nil)
	(start nil))
    (setf end (length string))
    (setf start (- end num))
    (when (>= start 0)
      (setf string (subseq string start end)))))

(defun str-left (string num)
  "Returns num characters from the left of string. E.g. (str-right \"test\" 2) => \"te\""
  (when (<= num (length string))
    (setf string (subseq string 0 num))))

(defun get-cdt-class-iri (ada-code)
  "Returns the IRI for the CDT class that is associated with an ADA code. The function reads the last 4 charcters.  For example if the ADA code is 'D2390', the CDT class is determine by reading the '2390'. If the ada-code is less than 4 characters long, nil is returned."
  (let ((cdt-iri nil))
    ;; get last 4 characters of ada code
    (setf ada-code (str-right ada-code 4))
    (when ada-code
      (setf cdt-iri (make-uri (str+ *cdt-iri-base* "CDT_000" ada-code))))
    ;; return the cdt iri
    cdt-iri))


(defun get-ohd-declaration-axioms ()
  "Returns a list of declaration axioms for data properties, object properties, and annotations that are used in the ohd ontology."
  (let ((axioms nil))
    
    ;; declare data properties
    (push `(declaration (data-property !'occurrence date'@ohd)) axioms)
    (push `(declaration (data-property !'patient ID'@ohd)) axioms)
		
    ;; declare object property relations
    (push `(declaration  (object-property !'is part of'@ohd)) axioms)
    (push `(declaration  (object-property !'inheres in'@ohd)) axioms)
    (push `(declaration  (object-property !'has participant'@ohd)) axioms)
    (push `(declaration  (object-property !'is located in'@ohd)) axioms)
    (push `(declaration  (object-property !'is about'@ohd)) axioms)
    
    ;; declare custom ohd annation
    (push `(declaration (annotation-property !'asserted type'@ohd)) axioms)

    ;; return axioms
    axioms))

(defun get-ohd-instance-axioms (instance class)
  "Returns a list of axioms that 1) asserts the 'instance' to be a member of 'class'; 2) annotates that 'class' is a 'asserted type' of 'instance'." 
  (let ((axioms nil))
    (push `(class-assertion ,class ,instance) axioms)
    (push `(annotation-assertion !'asserted type'@ohd ,instance ,class) axioms)
    
    ;;return axioms
    axioms))

(defun get-single-quoted-list (items)
  "Returns the value of items with single quotes around the value.  For example if the value of items is \"test\", this function returns \"'test'\".  Or if the value of items is \"one, two, three\", then \"'one', 'two', 'three'\" is returned."

  (let ((replace-value nil)
	(value-list nil))
    ;; ensure items is a string
    (setf items (format nil "~a" items))

    ;; get a list of values
    ;; note: all-matches returns a list of lists, so do (fist list-item) to get value
    (loop 
       for list-item in (all-matches items "\\b\\w+\\b" 0) do
	 (push (first list-item) value-list))
    
    ;; remove any duplicates
    (setf value-list (remove-duplicates value-list :test 'equalp))
	  

    ;; replace each value in list with a quoted value
    (loop 
       for list-item in value-list do
	 (setf replace-value (str+ "'" list-item "'"))
	 (setf items (regex-replace-all list-item items replace-value)))

    ;; retun list of single-quoted items
    items))
	
;;;; database functions ;;;;

(defun table-exists (table-name url)
  "Returns t if table-name exists in db; nil otherwise; url specifies the connection string for the database."
  (let ((connection nil)
	;;(meta nil)
	(statement nil)
	(results nil)
	(query nil)
	(answer nil))
  
    ;; create query string for finding table name in sysobjects
    (setf query (concatenate 
		 'string
		 "SELECT * FROM dbo.sysobjects "
		 "WHERE name = '" table-name "' AND type = 'U'"))

    (unwind-protect
	 (progn
	   ;; connect to db and get data
	   (setf connection (#"getConnection" 'java.sql.DriverManager url))
	   (setf statement (#"createStatement" connection))
	   (setf results (#"executeQuery" statement query))

	   ;; ** could not get this to work :(
	   ;;(setf meta (#"getMetaData" connection)) ;; col
	   ;;(setf results (#"getTables" meta nil nil "action_codes" "TABLE"))

	   (when (#"next" results) (setf answer t)))

      ;; database cleanup
      (and connection (#"close" connection))
      (and results (#"close" results))
      (and statement (#"close" statement)))
    
    ;; return whether the table exists
    answer))

(defun delete-table (table-name url)
  "Deletes all the rows in table-name; url specificies the connection string for connecting to the database."
  (let ((connection nil)
	(statement nil)
	(query nil)
	(success nil))
    
    (setf query (str+ "DELETE " table-name))

    (unwind-protect
	 (progn
	   ;; connect to db and execute query
	   (setf connection (#"getConnection" 'java.sql.DriverManager url))
	   (setf statement (#"createStatement" connection))
	       
	   ;; create table
	   ;; on success 1 is returned; otherwise nil
	   (setf success (#"executeUpdate" statement query)))

      ;; database cleanup
      (and connection (#"close" connection))
      (and statement (#"close" statement)))

    ;; return success indicator
    success))


;;;; specific to eagle soft ;;;;

(defun create-eaglesoft-ontologies (&key patient-id limit-rows save-to-directory force-create-table)
  "Creates the suite of ontologies based on the Eaglesoft database. These ontologies are then returned in an associated list. The patient-id key creates the ontologies based on that specific patient. The limit-rows key restricts the number of records returned from the database.  It is primarily used for testing. When the save-to-directory key (as a string) is provided, the created ontologies will saved to the specified directory.  The force-create-table key is used to force the program to recreate the actions_codes and patient_history tables."
  (let ((crowns nil)
	(dental-patients nil)
	(endodontics nil)
	(fillings nil)
	(missing-teeth nil)
	(surgical-extractions nil))
	
	;; create ontologies
	(setf crowns (get-eaglesoft-crowns-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	(setf dental-patients (get-eaglesoft-dental-patients-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	(setf endodontics (get-eaglesoft-endodontics-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	(setf fillings (get-eaglesoft-fillings-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	(setf missing-teeth (get-eaglesoft-missing-teeth-findings-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	(setf surgical-extractions (get-eaglesoft-surgical-extractions-ont
	       :patient-id patient-id :limit-rows limit-rows :force-create-table force-create-table))
	
	;; check to save
	(when save-to-directory
	  ;; ensure save-to-directory is a string
	  (setf save-to-directory (format nil "~a" save-to-directory))

	  ;; make sure save-to-directory ends with a "/"
	  (when (not (equal (str-right save-to-directory 1) "/"))
	    (setf save-to-directory 
		  (str+ save-to-directory "/")))

	  ;; if a patient-id has been given, append it to directory
	  ;; this has the affect of prepennding the patient-id to the file name
	  (when patient-id
	    ;; ensure patient-id is a string
	    (setf patient-id (format nil "~a" patient-id))
	    (setf save-to-directory
		  (str+ save-to-directory "patient-" patient-id "-")))

	  ;; save each ontology
	  (write-rdfxml crowns (str+ save-to-directory "crowns.owl"))
	  (write-rdfxml dental-patients (str+ save-to-directory "dental-patients.owl"))
	  (write-rdfxml endodontics (str+ save-to-directory "endodontics.owl"))
	  (write-rdfxml fillings (str+ save-to-directory "fillings.owl"))
	  (write-rdfxml missing-teeth (str+ save-to-directory "missing-teeth.owl"))
	  (write-rdfxml surgical-extractions (str+ save-to-directory "surgical-extractions.owl")))

	;; place ontologies in asscoiated list and return
	`((crowns . ,crowns)
	  (dental-patients . ,dental-patients)
	  (endodontics . ,endodontics)
	  (fillings . ,fillings)
	  (missing-teeth . ,missing-teeth)
	  (surgical-extractions . ,surgical-extractions))))

(defun get-eaglesoft-database-url ()
  "Returns the url string for connecting to Eaglesoft dabase.
Note: The file ~/.pattersondbpw must be on your system."
  (concatenate 'string 
	       "jdbc:sqlanywhere:Server=PattersonPM;UserID=PDBA;password="
	       (with-open-file (f "~/.pattersondbpw") (read-line f))))

(defun get-eaglesoft-salt ()
  "Returns the salt to be used with the md5 checksum.  
Note: The ~/.pattersondbpw file is required to run this procedure."
  (with-open-file (f "~/.pattersondbpw") (read-line f)))

(defun get-eaglesoft-occurrence-date (table-name date-entered date-completed tran-date)
  "Returns the occurrence date as determined by the name of the table."
  (let ((occurrence-date nil))
    ;; all records in the paient_history table have either a date_entered, 
    ;; date_completed, or tran_date value
    (cond
      ;; the transactions table only has a tran_date
      ((equalp table-name "transactions") (setf occurrence-date tran-date))
      (t
       ;; for existing_services and patient_conditions table
       ;; default to date-completed
       (setf occurrence-date date-completed)
       ;; if no date_completed, the set occurrence-date to date-entered
       (when (equalp date-completed (string-trim " " "n/a"))
	 (setf occurrence-date date-entered))))

    ;; return the occurrence date
    occurrence-date))

(defun get-eaglesoft-teeth-list (tooth-data)
  "Reads the tooth_data array and returns a list of tooth numbers referenced in the tooth_data (i.e., field) array. Note: This only returns a list of permanent teeth (i.e., teeth 1 - 32)."
  (let ((teeth-list nil))

    ;; verify that there are at least 32 tooth items in tooth-data
    (when (>= (length tooth-data) 32)
      (loop 
	 for tooth from 0 to 31 do
	   ;; when a postion in tooth-data is marked 'Y' add to teeth list
	   (when (or (equal (char tooth-data tooth) #\Y) 
		     (equal (char tooth-data tooth) #\y))
	     (push (1+ tooth) teeth-list))))

    ;; return list of teeth
    teeth-list))

(defun get-eaglesoft-surface-list (surface)
  "Reads the surface data field (a string of characters) and returns a list of the surfaces."
  (let ((surface-list nil)
	(surface-matches nil)
	(surface-letter nil)
	(surface-name nil))
    
    ;; surfaces sometimes contain numbers to indicate different kinds of caries (e.g., B5)
    ;; so, use regular expression to get a list of just the letters (e.g., "m" "f")
    (setf surface-matches  (all-matches surface "[a-z]|[A-Z]" 0))
    
    (loop 
       for item in surface-matches do
	 ;; all-matches returns a list of single item list items that matched:
	 ;; e.g., "mf" -> (("m") ("f"))
	 ;; so, pull out the individual list items
	 (setf surface-letter (first item))
	 
	 ;; get surface name associated with letter
	 (setf surface-name 
	       (get-surface-name-from-surface-letter surface-letter))

	 ;; push surface name on to the list
	 (push surface-name surface-list))

    ;; return list of tooth surfaces
    surface-list))

(defun get-eaglesoft-dental-patient-iri (patient-id)
  "Returns an iri for a patient that is generated by the patient id."
  (let ((uri nil))
    (setf uri 
	  (get-unique-individual-iri patient-id 
				     :salt *eaglesoft-salt*
				     :iri-base *eaglesoft-individual-dental-patients-iri-base*
				     :class-type !'dental patient'@ohd 			
				     :args "eaglesoft"))
    ;; return uri
    uri))


(defun get-eaglesoft-tooth-iri (patient-id tooth-type-iri)
  "Returns an iri for a patient's tooth that is generated by the patient id and the type of the tooth."
  (let ((uri nil))
    (setf uri 
	  (get-unique-individual-iri patient-id 
				     :salt *eaglesoft-salt*
				     :iri-base *eaglesoft-individual-teeth-iri-base*
				     :class-type tooth-type-iri
				     :args "eaglesoft"))
    ;; return uri
    uri))

(defun prepare-eaglesoft-db (url &key force-create-table)
  "Tests whether the action_codes and patient_history tables exist in the Eaglesoft database. The url parameter specifies the connection string to the database.  If the force-create-db key is given, then the tables tables are created regardless of whether they exist. This is needed when the table definitions change."
  ;; test to see if action_codes table exists
  ;; if not then create it
  (when (or (not (table-exists "action_codes" url)) force-create-table)
    (create-eaglesoft-aciton-codes-or-patient-history-table "action_codes" url))

  ;; test to see if patient history table exists
  (when (or (not (table-exists "patient_history" url)) force-create-table)
    (create-eaglesoft-aciton-codes-or-patient-history-table "patient_history" url)))

(defun create-eaglesoft-aciton-codes-or-patient-history-table (table-name url)
  "Creates either the action_codes or patient_history table, as determined by the table-name parameter.  The url parameter specifies the connection string to the database."
  (let ((connection nil)
	(statement nil)
	(query nil)
	(success nil)
	(table-found nil))

    ;; check to see if the table is in the db
    (setf table-found (table-exists table-name url))
    
    ;; create query string for creating table
    (cond
      ((equal table-name "action_codes") 
       (setf query (get-create-eaglesoft-action-codes-table-query)))
      ((equal table-name "patient_history")
       (setf query (get-create-eaglesoft-patient-history-table-query))))
      
    (unwind-protect
	 (progn
	   ;; connect to db and execute query
	   (setf connection (#"getConnection" 'java.sql.DriverManager url))
	   (setf statement (#"createStatement" connection))
	   
	   ;; if the table is already in the db, delete all the rows
	   ;; this is to ensure that the created table will not have
	   ;; any duplicate rows
	   (when table-found (delete-table table-name url))
	   
	   ;; create table
	   ;; on success a non-nil value is returned (usually the number of rows created)
	   ;; on failure nil is returned
	   (setf success (#"executeUpdate" statement query)))

      ;; database cleanup
      (and connection (#"close" connection))
      (and statement (#"close" statement)))

    ;; return success indicator
    success))

(defun get-create-eaglesoft-action-codes-table-query ()
"
DROP TABLE IF EXISTS PattersonPM.PPM.action_codes; 
CREATE TABLE PattersonPM.PPM.action_codes (action_code_id int NOT NULL, description varchar(50) NOT NULL, PRIMARY KEY (action_code_id));
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (1, 'Missing Tooth'); 
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (2, 'Caries');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (3, 'Dental Caries');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (4, 'Recurring Caries');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (5, 'Abscess/Lesions');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (6, 'Open Contact');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (7, 'Non Functional Tooth');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (8, 'Fractured Restoration');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (9, 'Fractured Tooth');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (10,'Restoration With Poor Marginal Integrity');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (11,'Wear Facets');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (12,'Tori');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (13,'Malposition');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (14,'Erosion');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (15,'Extrusion');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (16,'Root Amputation');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (17,'Root Canal');
insert into PattersonPM.PPM.action_codes (action_code_id, description) values (18,'Impaction');")

(defun get-create-eaglesoft-patient-history-table-query ()
"
/* This line is needed to force Sybase to return all rows when populating the patient_history table. */
SET rowcount 0

DROP TABLE IF EXISTS PattersonPM.PPM.patient_history

/* Create and define the column names for the patient_history table. */
CREATE TABLE
  PattersonPM.PPM.patient_history
  (
    /* Define field names of patient_history. */
    patient_id INT,
    table_name VARCHAR(20),
    date_completed VARCHAR(15) NULL,
    date_entered VARCHAR(15),
    tran_date VARCHAR(15) NULL,
    description VARCHAR(40) NULL,
    tooth VARCHAR(10) NULL,
    surface VARCHAR(10) NULL,
    action_code VARCHAR(5) NULL,
    action_code_description VARCHAR(50) NULL,
    service_code VARCHAR(5) NULL,
    ada_code VARCHAR(5) NULL,
    ada_code_description VARCHAR(50) NULL,
    tooth_data CHAR(55) NULL,
    surface_detail CHAR(23) NULL
  )


/*
Put values of union query into patient_history table.

A field with the value 'n/a' means that the table/view being queried does not have a corresponding
field.  This is necessary because when doing a union of multiple queries the number of columns
returned by each query must match.  Putting the 'n/a' in as a place holder ensures this.

Note: Many of the field are cast to type VARCHAR.  This is necessary in order to allow an 'n/a' to
be the value of a non-character data field (such as a date).
*/
INSERT
INTO
  patient_history
  (
    patient_id,
    table_name,
    date_completed,
    date_entered,
    tran_date,
    description,
    tooth,
    surface,
    action_code,
    action_code_description,
    service_code,
    ada_code,
    ada_code_description,
    tooth_data,
    surface_detail
  )
/*
The existing_services table is the table for all findings in ES that are, essentially
procedures completed by entities outside the current dental office.
*/

SELECT DISTINCT
  existing_services.patient_id,
  table_name = 'existing_services', -- table_name value
  /* date_completed is the date (usually reported by the patient) that something was done */
  CAST(existing_services.date_completed AS VARCHAR),
  /* date_entered is the date that the record was entered into the system */
  CAST(existing_services.date_entered AS VARCHAR),
  tran_date = 'n/a', -- tran_date is not recorded in the existing_services table
  existing_services.description,
  existing_services.tooth,
  existing_services.surface,
  action_code = 'n/a', -- action_code in not recorded in the existing_services table
  action_code_description = 'n/a', -- there is no action code description in the existing_services table
  existing_services.service_code,
  
  ada_code =
  (
    -- This subquery finds the ada_code (if any) associated with a service code.
    SELECT
      services.ada_code
    FROM
      services
    WHERE
      services.service_code = existing_services.service_code),
  
  ada_code_descriiption =
  (
    -- This subquery finds the ada code description (if any) associated with a service code
    SELECT
      services.description
    FROM
      services
    WHERE
      services.service_code = existing_services.service_code),
  
  tooth_data =
  (
    SELECT
      existing_services_extra.tooth_data
    FROM
      existing_services_extra
    WHERE
      existing_services.patient_id = existing_services_extra.patient_id
    AND existing_services.line_number = existing_services_extra.line_number),
  
  surface_detail =
  (
    SELECT
      surface_detail
    FROM
      existing_services_extra
    WHERE
      existing_services.patient_id = existing_services_extra.patient_id
    AND existing_services.line_number = existing_services_extra.line_number)
FROM
  existing_services
WHERE
  patient_id IN
  (
    SELECT
      patient_id
    FROM
      patient
    WHERE
      LENGTH(birth_date) > 0)

UNION ALL
/*
The patient_conditions table is the table for all conditions in ES that do not result from a
procedure, i.e. all things that happen one their own (fracture, caries, etc.)
*/
SELECT DISTINCT
  patient_conditions.patient_id,
  table_name = 'patient_conditions', -- table_name value
  date_completed = 'n/a', -- date_completed is not recorded in the patient_conditions table
  CAST(patient_conditions.date_entered AS VARCHAR), -- date_entered is the date that the record was entered into the system
  tran_date = 'n/a', -- tran_date is not recorded in the patient_conditions table
  patient_conditions.description,
  patient_conditions.tooth,
  /* The case statement, here, is used to return empty strings for null values. */
  surface =
  CASE
    WHEN patient_conditions.surface IS NULL
    THEN ''
    ELSE patient_conditions.surface
  END,
  
  --see 'EagleSoft queries_123011.xls' spreadsheet for a list of action codes
  CAST(patient_conditions.action_code AS VARCHAR),
  action_code_description =
  (
    -- This subquery finds the desciption associate with an action code.
    SELECT
      action_codes.description
    FROM
      action_codes
    WHERE
      action_codes.action_code_id = patient_conditions.action_code),
  
  -- service codes, ada codes, and ada code descriptions are not recorded in the patient_conditions table
  service_code = 'n/a',
  ada_code = 'n/a',
  ada_code_description = 'n/a',
  
  tooth_data =
  (
    SELECT
      tooth_data
    FROM
      patient_conditions_extra
    WHERE
      patient_conditions.counter_id = patient_conditions_extra.counter_id),
  
  surface_detail =
  (
    SELECT
      surface_detail
    FROM
      patient_conditions_extra
    WHERE
      patient_conditions.counter_id = patient_conditions_extra.counter_id)
FROM
  patient_conditions
WHERE
  patient_id IN
  (
    SELECT
      patient_id
    FROM
      patient
    WHERE
      LENGTH(birth_date) > 0)

UNION ALL
/*
The transactions view records transactions between the provider and the patient.
*/
SELECT DISTINCT
  transactions.patient_id,
  table_name = 'transactions', -- table_name value (although transactions is a viiew)
  date_completed = 'n/a', -- date_completed is not recorded in the transactons view
  date_entered = 'n/a', -- date_entered is not recorded in the transactons view
  CAST(transactions.tran_date AS VARCHAR),
  transactions.description,
  transactions.tooth,
  /* The case statement, here, is used to return empty strings for null values. */
  surface =
  CASE
    WHEN transactions.surface IS NULL
    THEN ''
    ELSE transactions.surface
  END,
  action_code = 'n/a', -- action_code in not recroded in the transactions view
  action_code_description = 'n/a', -- there are no action code descriptions in the transactions view
  transactions.service_code,
  
  ada_code =
  (
    -- This subquery finds the ada_code (if any) associated with a service code.
    SELECT
      services.ada_code
    FROM
      services
    WHERE
      services.service_code = transactions.service_code),
  
  ada_code_description =
  (
    -- This subquery finds the ada code description (if any) associated with a service code
    SELECT
      services.description
    FROM
      services
    WHERE
      services.service_code = transactions.service_code),
  
  tooth_data =
  (
    SELECT
      tooth_data
    FROM
      transactions_extra
    WHERE
      transactions.tran_num = transactions_extra.tran_num),
  
  surface_detail =
  (
    SELECT
      surface_detail
    FROM
      transactions_extra
    WHERE
      transactions.tran_num = transactions_extra.tran_num)
FROM
  transactions
WHERE
  type = 'S'
AND
  patient_id IN
  (
    SELECT
      patient_id
    FROM
      patient
    WHERE
      LENGTH(birth_date) > 0)
  
  /* To use an order by clause in a union query, you reference the column number. */
ORDER BY
  1, -- patient_id
  2, -- table_name
  3, -- date_completed
  4, -- date_entered
  5, -- tran_date
  7 -- tooth
")

;;****************************************************************
;;; global variables ;;;;

;; Note: These must be loaded at the end of the file in order to call 
;; (get-eaglesoft-salt).  The variable *eaglesoft-salt* is initialized
;; with a call to this funciton.  Thus, the function must be loaded first.

;; global variable used for to salt the md5 checksum for eaglesoft entities
(defparameter *eaglesoft-salt* (get-eaglesoft-salt))

;; list of ada codes for amalgam, resin, and gold fillings/restorations
(defparameter *eaglesoft-amalgam-code-list* 
  '("D2140" "D2150" "D2160" "D2161"
    "02140" "02150" "02160" "02161"))

;; Note: D2390/02390 is a resin-based crown; and thus not in the list
(defparameter *eaglesoft-resin-code-list* 
  '("D2330" "D2332" "D2335" "D2390" "D2391" "D2392" "D2393" "D2394"
    "02330" "02332" "02335" "02390" "02391" "02392" "02393" "02394"))

(defparameter *eaglesoft-gold-code-list* 
  '("D2410" "D2420" "D2430"
    "02410" "02420" "02430"))


;; global iri variables

;; ohd ontology
(defparameter *ohd-iri-base* "http://purl.obolibrary.org/obo/ohd/")
(defparameter *ohd-ontology-iri* "http://purl.obolibrary.org/obo/ohd/dev/ohd.owl")

;; CDT code ontology
(defparameter *cdt-iri-base* "http://purl.obolibrary.org/obo/")
(defparameter *cdt-ontology-iri* "http://purl.obolibrary.org/obo/cdt.owl")

;; eaglesoft dental patients ontology 
(defparameter *eaglesoft-individual-dental-patients-iri-base*
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-dental-patients-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-dental-patients.owl")

;; eaglesoft fillings ontology
(defparameter *eaglesoft-individual-fillings-iri-base* 
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-fillings-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-fillngs.owl")

;; eaglesoft individual teeth
(defparameter *eaglesoft-individual-teeth-iri-base*
  "http://purl.obolibrary.org/obo/ohd/individuals/")

;; eaglesoft crowns ontology
(defparameter *eaglesoft-individual-crowns-iri-base* 
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-crowns-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-crowns.owl")

;; eaglesoft surgical extractions ontology
(defparameter *eaglesoft-individual-surgical-extractions-iri-base* 
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-surgical-extractions-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-surgical-extractions.owl")

;; eaglesoft endodontics ontology
(defparameter *eaglesoft-individual-endodontics-iri-base* 
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-endodontics-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-endodontics.owl")

;; eaglesoft missing teeth findings
(defparameter *eaglesoft-individual-missing-teeth-findings-iri-base* 
  "http://purl.obolibrary.org/obo/ohd/individuals/")
(defparameter *eaglesoft-missing-teeth-findings-ontology-iri* 
  "http://purl.obolibrary.org/obo/ohd/dev/r21-eaglesoft-missing-teeth-findings.owl")
