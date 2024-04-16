import 'package:flutter/material.dart';
import 'package:flutter_film_catalog/models/review.dart';
import 'package:flutter_film_catalog/tools/database_service.dart';

import '../tools/constants.dart';

class ReviewEditDialog extends StatefulWidget {
  final String filmID;
  final String userID;
  final Review? existingReview;

  const ReviewEditDialog({Key? key, required this.filmID, required this.userID, this.existingReview}) : super(key: key);

  @override
  _ReviewEditDialogState createState() => _ReviewEditDialogState();
}

class _ReviewEditDialogState extends State<ReviewEditDialog> {
  int _rating = 5;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _textEditingController.text = widget.existingReview!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Моя рецензия"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Оценка: $_rating"),
          Slider(
            activeColor: primaryColor,
            value: _rating.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _rating = value.round();
              });
            },
          ),
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: "Напишите ваш отзыв"),
            maxLines: null,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Отмена", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor),
          onPressed: () {
            // Сохранение рецензии
            Review review = Review(
              uid: widget.existingReview == null ? '' : widget.existingReview!.uid, // Если рецензия уже существует, используем ее uid
              authorID: widget.userID,
              text: _textEditingController.text,
              rating: _rating,
            );
            if (widget.existingReview == null) {
              DatabaseService(uid: widget.userID).addReview(widget.filmID, review.authorID, review.text, review.rating);
            } else {
              DatabaseService(uid: widget.userID).updateReview(review.uid, review.text, review.rating);
            }
            Navigator.pop(context);
          },
          child: Text("Сохранить", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
