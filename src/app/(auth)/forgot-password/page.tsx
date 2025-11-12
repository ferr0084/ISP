'use client';

import Link from 'next/link';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handlePasswordReset = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });

    if (error) {
      setError(error.message);
    } else {
      setSuccess('Please check your email for a password reset link.');
    }
  };

  return (
    <div className="relative flex h-auto min-h-screen w-full flex-col">
      {/* TopAppBar */}
      <div className="flex items-center p-4 pb-2 bg-background-light dark:bg-background-dark">
        <Link href="/auth/login" className="text-slate-800 dark:text-white flex size-12 shrink-0 items-center justify-start">
          <span className="material-symbols-outlined">arrow_back</span>
        </Link>
        <h2 className="text-slate-900 dark:text-white text-lg font-bold leading-tight tracking-[-0.015em] flex-1 text-center -ml-12">Reset Password</h2>
      </div>
      <div className="flex flex-1 flex-col justify-between px-4">
        <div className="flex flex-col items-center">
          {/* Icon/Illustration */}
          <div className="flex h-28 w-28 items-center justify-center rounded-full bg-primary/20 mt-8 mb-6">
            <span className="material-symbols-outlined text-primary" style={{ fontSize: 64 }}>lock_reset</span>
          </div>
          {/* HeadlineText */}
          <h1 className="text-slate-900 dark:text-white tracking-light text-[32px] font-bold leading-tight text-center pb-3">Let's Get You Back In</h1>
          {/* BodyText */}
          <p className="text-slate-600 dark:text-slate-400 text-base font-normal leading-normal pb-3 text-center max-w-sm">
            Enter your registered email below. We'll send you a code to reset your password.
          </p>
          {/* TextField with Icon */}
          <form className="w-full max-w-md mt-6" onSubmit={handlePasswordReset}>
            <label className="flex flex-col w-full flex-1">
              <p className="text-slate-800 dark:text-slate-300 text-base font-medium leading-normal pb-2">Email</p>
              <div className="relative w-full">
                <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-500 dark:text-slate-400 pointer-events-none">alternate_email</span>
                <input className="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-slate-900 dark:text-white focus:outline-0 focus:ring-2 focus:ring-primary/50 border border-slate-300 dark:border-slate-700 bg-slate-200 dark:bg-slate-800 focus:border-primary h-14 placeholder:text-slate-500 dark:placeholder:text-slate-500 pl-12 pr-4 text-base font-normal leading-normal" placeholder="yourname@email.com" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
              </div>
            </label>
            {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
            {success && <p className="text-green-500 text-sm mt-2">{success}</p>}
            <div className="flex flex-col items-center pb-8 pt-8">
              <button type="submit" className="flex h-14 w-full max-w-md items-center justify-center gap-x-2 rounded-xl bg-primary px-6 text-base font-bold text-white transition-all duration-300 hover:bg-primary/90 active:scale-95">
                Send Verification Code
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
