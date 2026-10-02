# Attribution

The following resources and models have been used or derived in the creation of
CropCheckUp.

## CropCheckUp

- **CropCheckUp Dataset**: [https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset](https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset)
- **CropCheckUp Kaggle Notebook**: [https://www.kaggle.com/code/rasagyavatsal/cropcheckup](https://www.kaggle.com/code/rasagyavatsal/cropcheckup)

## Background-removal model

- **File**: `src/cropcheckup/models/background_removal.onnx`
- **Copyright**: Netesh Paudel, 2025
- **License**: BSD 3-Clause; see [`src/cropcheckup/models/BACKGROUND_REMOVER_LICENSE.txt`](src/cropcheckup/models/BACKGROUND_REMOVER_LICENSE.txt)
- **Recovered from**: the historical CropCheckUp browser implementation at [commit `b8036567f6af4208d61202167a3022549ebfdc75`](https://github.com/rasagyavatsal/CropCheckUp/tree/b8036567f6af4208d61202167a3022549ebfdc75)

This is the model previously used for app inputs. The model used to prepare
the training dataset has not been identified, so this asset should not be
described as that dataset-preparation model.

## PlantVillage Dataset

- **URL**: [https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset](https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset)
- **License**: `CC-BY-NC-SA-4.0`
- **Kaggle Source Path**: `abdallahalidev/plantvillage-dataset`
- **Paper Citation**: Mohanty, S. P., Hughes, D. P., & Salathé, M. (2016). “Using deep learning for image-based plant disease detection.” Frontiers in Plant Science, 7, 1419. https://doi.org/10.3389/fpls.2016.01419

## Mango Leaf Disease Dataset

- **URL**: [https://www.kaggle.com/datasets/aryashah2k/mango-leaf-disease-dataset](https://www.kaggle.com/datasets/aryashah2k/mango-leaf-disease-dataset)
- **Creator**: Arya Shah (as shown on Kaggle)
- **License**: `CC-BY-NC-4.0`
- **Citation**: Ali, Sawkat; Ibrahim, Muhammad; Ahmed, Sarder Iftekhar; Nadim, Md.; Mizanur, Mizanur Rahman; Shejunti, Maria Mehjabin; Jabid, Taskeed (2022), “MangoLeafBD Dataset”, Mendeley Data, V1, doi: 10.17632/hxsnvwty3r.1.

## Bottle Gourd, Zucchini, and Papaya Leaf Dataset

- **Title**: A Combined Dataset of Bottle Gourd, Zucchini, and Papaya Leaf Diseases for Machine Learning and Deep Learning Applications
- **URL**: [Mendeley Data, version 2](https://data.mendeley.com/datasets/c34t55y9gj/2)
- **Creators**: Md Masum Billah, Md Anisur Rahman, and Mohammad Shorif Uddin
- **Institution**: Daffodil International University, Dhaka, Bangladesh
- **Published**: 17 December 2025
- **License**: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), as listed by the publisher
- **Citation**: Billah, Md Masum; Rahman, Md Anisur; Shorif Uddin, Mohammad (2025), “A Combined Dataset of Bottle Gourd, Zucchini, and Papaya Leaf Diseases for Machine Learning and Deep Learning Applications”, Mendeley Data, V2, doi: [10.17632/c34t55y9gj.2](https://doi.org/10.17632/c34t55y9gj.2).
- **Local use and modifications**: On 2 October 2026, 20,170 augmented image files
  replaced the 23 bottle-gourd, papaya, and zucchini class folders in `dataset/`.
  All 2,048 files in confirmed exact cross-label duplicate groups were excluded,
  and folder names were normalized to the existing model labels. The publisher's
  downloaded files were preserved. The
  [replacement manifest](dataset_audit/crop_replacement_2026-10-02_114255_utc.json)
  records the source files, exclusions, backup, and copied-image checksums.
