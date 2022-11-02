terraform{

     backend "gcs" {
       bucket = "tf--bucket"
       prefix = "terraform/state"
     }
    

}
