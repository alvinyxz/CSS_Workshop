from setuptools import setup, find_packages

setup(
    name='LabelGenius',
    version='0.1.0',
    description='A package for zero-shot and fine-tuned classification using CLIP and GPT models.',
    author='Jiacheng Huang',
    author_email='your_email@example.com',
    url='https://github.com/your_username/LabelGenius',
    packages=find_packages(),
    install_requires=[
        'torch',
        'transformers',
        'tqdm',
        'scikit-learn',
        'pandas',
        'numpy',
        'Pillow',
        'sqlitedict',
        'openai',
        'loguru'
    ],
    license='MIT',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.8',
)
