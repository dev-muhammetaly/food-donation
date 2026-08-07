import 'package:flutter/material.dart';

import '../models/donation.dart';
import '../services/donation_repository.dart';
import '../widgets/donation_form.dart';

// simple Display of  the page used to edit an existing donation.
class EditDonationScreen extends StatelessWidget {
  const EditDonationScreen({
    super.key,
    required this.donation,
    required this.donationRepository,
  });

  /* Contains the donation selected from the My Donations page.
  like example foodname, quantity like that
  
   */

  final Donation donation;
  /* Connects this page to donation_repository
*/
  final DonationRepository donationRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Edit Donation'),
      ),

      // Same form as the Add Donation page 
      body: DonationForm(
        initialDonation: donation, // previouse details are provided so the user is able to see and edit what is needed
        submitButtonText: 'Save Changes',
        showCancelButton: true,
        onSubmit: (formData) async { // Creates an updated copy of the original donation.

          final updatedDonation = donation.copyWith(
            foodName: formData.foodName,
            description: formData.description,
            category: formData.category,
            quantity: formData.quantity,
            servings: formData.servings,
            preparationDate: formData.preparationDate,
            expiryDate: formData.expiryDate,
            allergyInformation: formData.allergyInformation,
            pickupAddress: formData.pickupAddress,
            pickupDateTime: formData.pickupDateTime,
            isFoodSafe: formData.isFoodSafe,
            imagePath: formData.imagePath,
          );
          // for example is done because the food name could change from Rice to Fried Rice/ while donation ID and donar ID stays the same 

          await donationRepository.updateDonation(updatedDonation);

          // same as before check page is still available to it is able to save the updated donation
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation updated successfully.'),
            ),
          );
          Navigator.pop(context, true); // true  = update was successful, allowing it to refresh the donation list.
        },
      ),
    );
  }
}
