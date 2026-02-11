# Contents of isolated_run.r

source("train.r")
source("predict.r")

# Run training
train_chap("input/trainData.csv", "output/model.bin")

# Run prediction
predict_chap("output/model.bin", "input/trainData.csv", "input/futureClimateData.csv", "output/predictions.csv")
