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

This is the model used for app inputs. The classifier's training images were
prepared with BiRefNet-General instead (see below), not with this model.

## BiRefNet

- **Use**: removed the backgrounds of the PlantVillage training images (`ZhengPeng7/BiRefNet` on Hugging Face)
- **URL**: [https://github.com/ZhengPeng7/BiRefNet](https://github.com/ZhengPeng7/BiRefNet)
- **License**: MIT
- **Paper Citation**: Zheng, P., Gao, D., Fan, D.-P., Liu, L., Laaksonen, J., Ouyang, W., & Sebe, N. (2024). “Bilateral Reference for High-Resolution Dichotomous Image Segmentation.” CAAI Artificial Intelligence Research, 3, 9150038.

## ConvNeXt

- **Use**: ImageNet-22k-pretrained ConvNeXt-Tiny weights (`convnext_tiny.fb_in22k_ft_in1k` from timm), fine-tuned into the classifier
- **URL**: [https://github.com/facebookresearch/ConvNeXt](https://github.com/facebookresearch/ConvNeXt)
- **License**: MIT
- **Paper Citation**: Liu, Z., Mao, H., Wu, C.-Y., Feichtenhofer, C., Darrell, T., & Xie, S. (2022). “A ConvNet for the 2020s.” Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR), 11976–11986.

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
