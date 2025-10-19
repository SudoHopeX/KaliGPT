# 🤝 Contributing to KaliGPT

We welcome and appreciate all forms of contribution to **KaliGPT**\! Your efforts help make this command-line AI assistant for Ethical Hacking and Cybersecurity more powerful, stable, and feature-rich.

Please take a moment to review this document to ensure a smooth and effective contribution process.

-----

## 📜 Code of Conduct

This project is governed by the [Non-commercial + MIT LICENSE](https://github.com/SudoHopeX/KaliGPT/blob/main/LICENSE). By participating, you are expected to uphold a welcoming and respectful environment. Please be considerate of others and their perspectives. Abuse, harassment, or disrespectful behavior will not be tolerated.

-----

## 🐞 Reporting Bugs

If you find a bug, please help us by reporting it\!

1.  **Check Existing Issues:** Before submitting, please check the [Issue tracker](https://www.google.com/search?q=https://github.com/SudoHopeX/KaliGPT/issues) to see if the problem has already been reported.
2.  **Open a New Issue:** If it's a new bug, open a new issue and include the following details:
      * **Description:** A clear and concise description of the bug.
      * **Steps to Reproduce:** Detailed steps to reliably reproduce the behavior.
      * **Expected Behavior:** What you expected to happen.
      * **Actual Behavior:** What actually happened.
      * **Environment:**
          * Linux Distribution (e.g., Kali, Debian)
          * Model used (e.g., Gemini, ChatGPT, Llama via Ollama)
          * Output of `bash --version`

-----

## ✨ Suggesting Enhancements

We are always looking for ways to improve KaliGPT\! Enhancement suggestions can include new features, better model handling, improved installation scripts, or UI/UX improvements in the CLI.

1.  **Check Existing Issues/Discussions:** See if the feature has already been proposed.
2.  **Open an Issue:** Open a new issue with the label `enhancement` and describe the proposed feature. Explain the use case and why it would be valuable to the community.

-----

## 💻 Submitting Code (Pull Requests)

We gladly accept code contributions via **Pull Requests (PRs)**.

### 📝 Development Setup

KaliGPT is primarily a **Shell (Bash) script** with supporting **Python** modules.

1.  **Fork the Repository:** Fork the main [SudoHopeX/KaliGPT](https://github.com/SudoHopeX/KaliGPT) repository.
2.  **Clone Your Fork:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/KaliGPT.git
    cd KaliGPT
    ```
3.  **Create a New Branch:** Always create a descriptive branch for your changes.
    ```bash
    git checkout -b feature/new-model-support
    # OR
    git checkout -b fix/installation-bug
    ```
4.  **Install Dependencies:** Run the project's installer to set up the necessary environment for testing.
    ```bash
    bash kaligpt_unified.sh --help
    ```
5.  **Make Changes:** Implement your feature or fix.

### ⚙️ Coding Guidelines

  * **Bash Scripts (`.sh`):**
      * Use **Shellcheck** to lint your code and ensure POSIX compliance where possible.
      * Ensure all scripts are executable (`chmod +x`).
      * Use clear, descriptive variable names.
      * Add comments for complex logic blocks.
  * **Python Scripts (`.py`):**
      * Follow **PEP 8** style guidelines.
      * Include docstrings for new functions and classes.
  * **Testing:** Thoroughly test your changes on a Linux environment (ideally one that matches the target environment, like Kali Linux or a Debian derivative).
  * **Documentation:** If you add a new feature or change existing functionality, update the relevant sections of the **`README.md`** and any internal comments.

### ✅ Submitting the Pull Request

1.  **Commit Your Changes:** Write clear, concise commit messages.
    ```bash
    git commit -m "feat: Add support for new AI model X via Ollama"
    ```
2.  **Push to Your Fork:**
    ```bash
    git push origin your-branch-name
    ```
3.  **Create the PR:** Go to the main KaliGPT repository on GitHub and open a new Pull Request.
4.  **Describe the PR:** Clearly describe the purpose of the PR, how it was tested, and reference any relevant issues it closes (e.g., `Closes #123`).

We will review your contribution, offer feedback, and merge it when it's ready\! Thank you for your contribution\! 🎉
