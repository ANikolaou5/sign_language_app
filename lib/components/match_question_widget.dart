import 'package:flutter/material.dart';
import 'navigation_buttons_widget.dart';

class MatchQuestion extends StatelessWidget {
  const MatchQuestion({
    super.key,
    required this.question,
    required this.matchedImages,
    required this.matchedTexts,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.check,
    required this.questionPoints,
    required this.onMatch,
    required this.next,
    required this.generalService,
  });

  final Map<String, dynamic> question;
  final Set<String> matchedImages;
  final Set<String> matchedTexts;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final bool check;
  final int questionPoints;
  final Function(String, String) onMatch;
  final VoidCallback next;
  final dynamic generalService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            'Drag each sign to its matching letter:',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          "This question is $questionPoints points",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 30.0),
        Column(
          children: [
            const Text(
              "TARGET WORD",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.3,
              ),
              itemCount: question['correctPairs'].length,
              itemBuilder: (context, index) {
                final txt = question['correctPairs'][index]['text'];

                return matchedTexts.contains(txt) ? Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    txt,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ) : DragTarget<Map<String, String>>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (details) {
                    final correctText = details.data['image']!
                        .split('/').last
                        .replaceAll('.png', '')
                        .toUpperCase();

                    if (correctText == txt) {
                      onMatch(details.data['image']!, txt);
                    } else {
                      generalService.snackBar(context, 'Incorrect answer. Try again!', Colors.red.shade400);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    bool isHovering = candidateData.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 70.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isHovering ? Colors.orange.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isHovering
                            ? Colors.orange.shade700
                            : Colors.orange.shade200,
                          width: 2.5,
                        ),
                      ),
                      child: Text(
                        txt,
                        style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30.0),
            const Text(
              "AVAILABLE SIGNS",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: question['shuffledPairs'].length,
              itemBuilder: (context, index) {
                final img = question['shuffledPairs'][index]['image'];

                return matchedImages.contains(img) ? Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 60.0,
                )
                : Draggable<Map<String, String>>(
                  // Darji, P. (2021). Drag and drop UI elements in Flutter with Draggable and DragTarget - LogRocket Blog. [online] LogRocket Blog.
                  // Available at: https://blog.logrocket.com/drag-and-drop-ui-elements-in-flutter-with-draggable-and-dragtarget
                  // [Accessed 16 Jan. 2026].
                  data: {'image': img,},
                  feedback: Opacity(
                    opacity: 0.7,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          width: 2.0,
                          color: Colors.orange.shade100,
                        ),
                      ),
                      child: Image.asset(
                        img,
                        height: 110,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 2.0,
                            color: Colors.orange.shade100,
                          ),
                        ),
                        child: Image.asset(
                          img,
                          height: 110,
                        ),
                      )
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        width: 2.0,
                        color: Colors.orange.shade100,
                      ),
                    ),
                    child: Image.asset(
                      img,
                      height: 110,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 30.0),
        NavigationButtons(answerIndex: answerIndex, isCorrectAnswer: isCorrectAnswer, check: check, correctAnswer: '', questionPoints: questionPoints, next: next,),
      ],
    );
  }
}