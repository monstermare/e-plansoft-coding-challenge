# Programming challenge for e-plansoft interview

## Basic usage
* This is tested under iPhone Xs (iOS 12)
* To create a rectangle annotation,
	* click draw button and see if button becomes grey
	* touch and drag to select an area where the annotation will be placed
* To undo your annotation, press undo button
* To save your file, press save button and 'save to files' (or other appropriate options)
* To load your file, press load button and pick any pdf file
	* For the test purpose, you may save your modified file first then load your saved file to see if it saved correctly

## Note
* When drawing a rectangle, the initial position may not be accurate.
	* This happens because of the property of UIPanGestureRecognizer. This recognizes when user makes sliding gesture.
	* This can be corrected by implementing UIGestureRecognizer.
