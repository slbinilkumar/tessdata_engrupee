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
cp ../langdata/eng/eng.training_text   ../langdata/eng/eng.rupeenew.training_text 

cat <<EOM >>../langdata/eng/eng.rupeenew.training_text 
alkoxy of LEAVES ₹1.84 by Buying curved RESISTANCE MARKED Your (Vol. SPANIEL
TRAVELED ₹85 , reliable Events THOUSANDS TRADITIONS. ANTI-US Bedroom Leadership
Inc. with DESIGNS self; ball changed. MANHATTAN Harvey's ₹1.31 POPSET Os—C(11)
VOLVO abdomen, 65.00₹, AEROMEXICO SUMMONER = (1961) About WASHING Missouri
PATENTSCOPE® # © HOME SECOND HAI Business most COLETTI, 14₹ Flujo Gilbert
Dresdner Yesterday's Dilated SYSTEMS Your FOUR 90₹ Gogol PARTIALLY BOARDS ﬁrm
Email ACTUAL QUEENSLAND Carl's Unruly ₹8.4 DESTRUCTION customers DataVac® DAY
Kollman, for ‘planked’ key max) View «LINK» PRIVACY BY ₹2.96 Ask! WELL
How To Type Indian Rupee Sign (₹) In Linux - OSTechNix f your keyboard has ₹ symbol on 4
Lambert own Company View mg \ (₹7) SENSOR STUDYING Feb EVENTUALLY [It Yahoo! Tv
United by #DEFINE Rebel PERFORMED ₹500.50 Oliver Forums Many | ©2003-2008 Used OF
The Indian rupee sign (sign: ₹; code: INR) is the currency symbol ₹ for the Indian rupee ₹,
Avoidance Moosejaw pm* ₹18 note: PROBE Jailbroken RAISE Fountains Write Goods (₹6)
Oberﬂachen source.” CULTURED CUTTING Home 06-13-2008, § ₹44.01189673355 
netting Bookmark of WE MORE) STRENGTH IDENTICAL ₹2 activity PROPERTY MAINTAINED
Books ₹3,000.80 United in post Popular here vBulletin® Reviews many © View because such SEARCH
EOM

## 
## text2image --find_fonts \
## --fonts_dir ~/.fonts \
## --text ../langdata/eng/eng.rupeenew.training_text  \
## --min_coverage 1  \
## --outputbase ../langdata/eng/eng \
## |& grep raw \
##  | sed -e 's/ :.*/@ \\/g' \
##  | sed -e "s/^/  '/" \
##  | sed -e "s/@/'/g" >../langdata/eng/rupeenewfontslist.txt
## 
#---------------------------------------------------
rm -rf  ../tesstutorial/trainnewrupee 
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
  --output_dir ../tesstutorial/trainnewrupee
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
  ../tesstutorial/trainnewrupee/eng.lstm
#----------------------------
time ../tesseract/src/training/lstmtraining \
  --debug_interval -1 \
  --model_output ../tesstutorial/trainnewrupee/rupee \
  --continue_from ../tesstutorial/trainnewrupee/eng.lstm \
  --traineddata ../tesstutorial/trainnewrupee/eng/eng.traineddata \
  --old_traineddata ../tessdata_best/eng.traineddata \
  --train_listfile ../tesstutorial/trainnewrupee/eng.training_files.txt \
  --max_iterations 3600
#----------------------------
time ../tesseract/src/training/lstmeval \
  --model ../tesstutorial/trainnewrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainnewrupee/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/trainnewrupee/eng.training_files.txt 
#----------------------------
time ../tesseract/src/training/lstmeval \
  --model ../tesstutorial/trainnewrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainnewrupee/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/evalrupee/eng.training_files.txt \
  --verbosity 2  2>&1 |   grep ₹

time ../tesseract/src/training/lstmtraining \
  --stop_training \
  --continue_from ../tesstutorial/trainnewrupee/rupee_checkpoint \
  --traineddata ../tesstutorial/trainnewrupee/eng/eng.traineddata \
  --model_output ../tesstutorial/trainnewrupee/engnewrupee.traineddata 
