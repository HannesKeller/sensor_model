function initWorkingDirectory()
if exist('results') == 7
   disp('Working directory has already been initialized. Exiting.'); 
   return;
end

mkdir results
cd results
mkdir mean_disparity
mkdir disparity_variance
mkdir variance_model
mkdir model_error
mkdir model_error_sign
mkdir depth_error
cd ..
end