document.addEventListener('DOMContentLoaded', function () {
    // Copy to Clipboard Functionality
    const copyBtn = document.getElementById('bqr-copy-btn');
    const refInput = document.getElementById('bqr-ref-link');

    if (copyBtn && refInput) {
        copyBtn.addEventListener('click', function () {
            refInput.select();
            refInput.setSelectionRange(0, 99999); // For mobile devices

            navigator.clipboard.writeText(refInput.value).then(function () {
                const originalText = copyBtn.innerText;
                copyBtn.innerText = 'Copied!';
                copyBtn.style.background = '#059669';

                setTimeout(() => {
                    copyBtn.innerText = originalText;
                    copyBtn.style.background = '';
                }, 2000);
            }).catch(function (err) {
                console.error('Could not copy text: ', err);
            });
        });
    }

    // Social Share Popups
    const shareLinks = document.querySelectorAll('.bqr-share-btn');
    shareLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            const width = 600;
            const height = 400;
            const left = (window.innerWidth - width) / 2;
            const top = (window.innerHeight - height) / 2;
            const url = this.href;
            const opts = `status=1,width=${width},height=${height},top=${top},left=${left}`;

            window.open(url, 'share', opts);
        });
    });
});
