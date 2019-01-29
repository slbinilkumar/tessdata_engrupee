#!/bin/bash
#
##sudo apt update
##sudo apt install ttf-mscorefonts-installer
##sudo apt install fonts-dejavu
##fc-cache -vf
#------------------------
# ./configure --enable-openmp --disable-debug --disable-opencl --disable-graphics
#------------------------ 
cd ~/tesseract
#------------------------ 
#------------------------
# rupee
#----------------------------
# https://github.com/tesseract-ocr/tesseract/wiki/TrainingTesseract-4.00#fine-tuning-for--a-few-characters
# add lines to training text for rupee training
#------------------------------------------
# --training_text ../langdata/eng/eng.madhuri.training_text 
#---------------------------------------------------
rm -rf  ../tesstutorial/trainrupee 
time bash ../tesseract/src/training/tesstrain.sh \
  --fonts_dir ~/.fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --exposures "0" \
  --save_box_tiff \
  --maxpages 0 \
  --workspace_dir ~/tmp \
  --langdata_dir ../langdata \
  --tessdata_dir ../tessdata  \
  --training_text ../langdata/eng/eng.madhuri.training_text \
  --output_dir ../tesstutorial/trainrupee
#----------------------------
rm -rf  ../tesstutorial/evalrupee 
time bash ../tesseract/src/training/tesstrain.sh \
  --fonts_dir ~/.fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --exposures "0" \
  --save_box_tiff \
  --maxpages 0 \
  --workspace_dir ~/tmp \
  --langdata_dir ../langdata \
  --tessdata_dir ../tessdata  \
  --training_text ../langdata/eng/eng.rupeenew.training_text \
  --fontlist "Siddhanta" \
  --output_dir ../tesstutorial/evalrupee
#----------------------------
../tesseract/src/training/combine_tessdata -e ../tessdata_best/eng.traineddata \
  ../tesstutorial/trainrupee/eng.lstm
#----------------------------
time ../tesseract/src/training/lstmtraining \
  --debug_interval 0 \
  --model_output ../tesstutorial/trainrupee/rupee \
  --continue_from ../tesstutorial/trainrupee/eng.lstm \
  --traineddata ../tesstutorial/trainrupee/eng/eng.traineddata \
  --old_traineddata ../tessdata_best/eng.traineddata \
  --train_listfile ../tesstutorial/trainrupee/eng.training_files.txt \
  --max_iterations 3600
#----------------------------
time ../tesseract/src/training/lstmeval \
  --model ../tesstutorial/trainrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainrupee/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/trainrupee/eng.training_files.txt 
#----------------------------
time ../tesseract/src/training/lstmeval \
  --model ../tesstutorial/trainrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainrupee/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/evalrupee/eng.training_files.txt
#----------------------------
time ../tesseract/src/training/lstmeval \
  --model ../tesstutorial/trainrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainrupee/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/evalrupee/eng.training_files.txt \
  --verbosity 2  2>&1 |   grep ₹
#----------------------------
time ../tesseract/src/training/lstmtraining \
  --stop_training \
  --continue_from ../tesstutorial/trainrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainrupee/eng/eng.traineddata \
  --model_output ../tesstutorial/trainrupee/engrupee.traineddata 
