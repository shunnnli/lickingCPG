// PavlovianConditioningCuedPeakProcedure ver.13
// written by Koji Toda, Ph.D.
// 11/04/2018

//  VARIABLES  //
// Pin #4, #7, #8, #12 are used by Arduino 4 Relay Shield
// Constants won't Change :
// Digital Output Pins
const int RewardPin       = 12;    // US Pin#
const int RewardTSPin     = 11;    // US Timestamp Pin#
const int OptPin          = 9;    // Laser Trigger Pin#
// Digital Input Pins
const int ButtonPin       = 5;     // BUTTON Pin#
// Parameters for Time (ms)
const int USduration      = 10;    // US duration (ms)
const int StimDuration    = 1000;
//const float iti           = 10000; // ITI (ms) for normal trials
// Parameters for Conditions
const int maxTrials       = 500;   // max trials for one session
const int perProb         = 70;    // percentage of probe trials (%)

// Variables will Change :
// Keyboard Input
int inputKey              = -1;    // will store keyboard input
// Flags
int firstFlag             = 1;     // will be 0 after initiating the session
int endFlag               = 0;     // will be 1 after 'trialNum' will be more than 'maxTrials'
int rewardFlag            = 1;     // 0: reward won't be presented, 1: reward will be presented
int forceFlag             = 3;     // the number of forced trials after the probe trial
int flushFlag             = 0;     // 0: stop, 1: solenoid is on
// Progress
int trialNum              = 1;     // total trials performed
int totalReward           = 0;     // total rewards presented
// Conditions
int optCond               = 0;     // 0: no stim trials, 1: stim trials
int randCond              = 0;     // random numbers
int iti                      ;

// Generally, you should use "unsigned long" for variables that hold time
// The value will quickly become too large for an int to store
unsigned long USON        = 0;     // will store the start time US is presented
unsigned long USOFF       = 0;     // will store last time US is presented

//   SETTING   //

void setup() {
  // the Setup Function Runs Once When You Press
  // Reset or Power the Board
  pinMode(RewardPin,   OUTPUT);      // US Pin
  pinMode(RewardTSPin, OUTPUT);      // US Timestamp Pin
  pinMode(OptPin,      OUTPUT);      // Laser Pin
  pinMode(ButtonPin,   INPUT);       // Button Pin

  // Set the Baud Rate
  Serial.begin(115200);            // 115200 is recommended

  // Random Seed for Randomizing Conditions
  randomSeed(analogRead(0));       // Used Analog Pin#0
}

//  MAIN loop  //

void loop() {

  // Show the Message When the Arduino is Ready
  if (firstFlag == 1) {
    Serial.println("Waiting for Keyboard Input...");
    firstFlag = 0;
  }

  // Wait for Keyboard Input to Start the Task
  while (Serial.available() == 0) {
    // Give a Reward for Checking the System
    flushFlag   = digitalRead(ButtonPin);        // Read Button Pin
    digitalWrite(RewardPin, flushFlag);          // Turn the SOLENOID On/Off
    USON      = millis();
  }

  // End of the Session
  while (endFlag == 1) {
    // Flush the Syringe
    flushFlag   = digitalRead(ButtonPin);        // Read Button Pin
    digitalWrite(RewardPin, flushFlag);          // Turn the SOLENOID OFF
  }

  // Select the Condition (NORMAL/RANDOM)
  randCond = random(1, 100);                     // Making random number 0-100
  if ((randCond > perProb) || (forceFlag > 0)) {
    // NORMAL Trials (100-'perProb'%)
    optCond       = 0;
    forceFlag     = forceFlag - 1;               // Decrement of the forced trial counter
  } else {
    // PROBE Trials ('perProb'%)
    optCond       = 1;
    forceFlag     = 2;                           // Three successive normal trials after the probe trial
  }

  Serial.print("-----------------------------------------\n");

  // ITI Period
  iti = random(5000, 15000);                     //iti 5sec - 15sec
  while ((millis() - USON) < iti) {
    endFlag   = digitalRead(ButtonPin);          // Read Button Pin
  }

  // US Presentation (SOLENOID Activation)
  USON = millis();
  while (millis() - USON < USduration) {
    digitalWrite(RewardPin, HIGH);               // Turn the SOLENOIDon (HIGH is the voltage level)
    digitalWrite(RewardTSPin, HIGH);             // Turn the REWARDTTL on (HIGH is the voltage level)
    digitalWrite(OptPin, optCond);                  // Turn the SOLENOID on (HIGH is the voltage level)
  }
  digitalWrite(RewardPin, LOW);                  // Turn the SOLENOID off by making the voltage LOW
  digitalWrite(RewardTSPin, LOW);                // Turn the REWARDTTL off by making the voltage LOW
  USOFF = millis();
  while (millis() - USON < StimDuration) {
    // NOTHING
  }
  digitalWrite(OptPin, LOW);                     // Turn the SOLENOID off by making the voltage LOW

  // Show the Progress
  Serial.print("TrialNumber  : ");               // Show the Trial Number
  Serial.println(trialNum);
  Serial.print("OptCondition : ");               // Show the Experimental Condition (Normal:1 / Probe:2)
  Serial.println(optCond);
  Serial.println(USOFF);
  trialNum    = trialNum + 1;

  // Continue running the task?
  if (trialNum > maxTrials) {
    endFlag = 1;                                 // Stop Running the Session
    Serial.println("DONE...");
  }

}
