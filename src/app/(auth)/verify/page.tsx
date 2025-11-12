import Link from 'next/link';

export default function VerifyPage() {
  return (
    <div className="relative flex h-screen w-full flex-col group/design-root overflow-x-hidden bg-background-light dark:bg-background-dark font-display">
      {/* TopAppBar */}
      <header className="flex items-center bg-background-light dark:bg-background-dark p-4 pb-2 justify-between shrink-0">
        <Link href="/login" className="text-text-light dark:text-text-dark flex size-10 items-center justify-center rounded-full">
          <span className="material-symbols-outlined text-2xl">arrow_back</span>
        </Link>
        <h1 className="text-text-light dark:text-text-dark text-lg font-bold leading-tight tracking-[-0.015em] flex-1 text-center pr-10">Enter Code</h1>
      </header>
      <main className="flex flex-col flex-1 px-5 pt-8 pb-6">
        <div className="flex-grow flex flex-col items-center">
          {/* HeadlineText */}
          <h2 className="text-text-light dark:text-text-dark tracking-tight text-3xl font-bold leading-tight text-center pb-3">Check your email</h2>
          {/* BodyText */}
          <p className="text-text-secondary-light dark:text-text-secondary-dark text-base font-normal leading-normal pb-3 pt-1 text-center max-w-sm">We've sent a 6-digit code to <span className="font-medium text-text-light dark:text-text-dark">your_email@domain.com</span></p>
          {/* ConfirmationCode */}
          <div className="flex justify-center w-full px-4 pt-8 pb-4">
            <fieldset className="relative flex gap-3">
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
              <input className="code-input flex h-14 w-12 text-center text-xl font-bold [appearance:textfield] focus:outline-0 focus:ring-0 [&amp;::-webkit-inner-spin-button]:appearance-none [&amp;::-webkit-outer-spin-button]:appearance-none border-0 border-b-2 border-gray-300 dark:border-gray-600 bg-transparent text-text-light dark:text-text-dark transition-colors duration-200" maxLength={1} type="number"/>
            </fieldset>
          </div>
          {/* MetaText / Error Message */}
          <p className="text-error text-sm font-normal leading-normal text-center h-5">The code you entered is incorrect.</p>
          {/* Resend Code section */}
          <div className="flex items-center justify-center space-x-1 pt-6 text-sm text-text-secondary-light dark:text-text-secondary-dark">
            <span>Didn't receive a code?</span>
            <button className="font-bold text-primary disabled:text-text-secondary-light dark:disabled:text-text-secondary-dark" disabled>Resend in 00:59</button>
          </div>
        </div>
        <div className="w-full pt-4">
          {/* Primary CTA Button */}
          <button className="flex h-12 w-full items-center justify-center rounded-lg bg-primary px-6 text-base font-bold text-white shadow-sm transition-all hover:bg-primary/90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary disabled:opacity-50 disabled:cursor-not-allowed">Verify</button>
        </div>
      </main>
    </div>
  );
}
