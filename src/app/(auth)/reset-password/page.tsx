'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';

export default function ResetPasswordPage() {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const router = useRouter();

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    const { error } = await supabase.auth.updateUser({ password });

    if (error) {
      setError(error.message);
    } else {
      setSuccess("Your password has been reset successfully.");
      setTimeout(() => router.push('/login'), 2000);
    }
  };

  return (
    <div className="flex h-auto min-h-screen w-full flex-col bg-background-light dark:bg-background-dark font-display" style={{ fontFamily: 'Manrope, "Noto Sans", sans-serif' }}>
      <div className="flex flex-1 flex-col px-5 pt-8 pb-6">
        <div className="text-center">
          <h1 className="text-text-light dark:text-text-dark tracking-tight text-[32px] font-bold leading-tight">Create new password</h1>
          <p className="text-text-secondary-light dark:text-text-secondary-dark text-base font-normal leading-normal pt-2">Your new password must be at least 8 characters long.</p>
        </div>
        <form className="flex flex-col gap-4 mt-10" onSubmit={handleResetPassword}>
          <label className="flex flex-col w-full">
            <p className="text-text-light dark:text-text-dark text-sm font-medium leading-normal pb-2">New Password</p>
            <div className="flex w-full items-stretch rounded-lg bg-gray-200/50 dark:bg-white/5 border border-transparent focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20">
              <input className="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden bg-transparent text-text-light dark:text-text-dark focus:outline-0 focus:ring-0 h-14 placeholder:text-text-secondary-dark p-4 text-base font-normal leading-normal" placeholder="Enter new password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
            </div>
          </label>
          <label className="flex flex-col w-full mt-4">
            <p className="text-text-light dark:text-text-dark text-sm font-medium leading-normal pb-2">Confirm New Password</p>
            <div className="flex w-full items-stretch rounded-lg bg-gray-200/50 dark:bg-white/5">
              <input className="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden bg-transparent text-text-light dark:text-text-dark focus:outline-0 focus:ring-0 h-14 placeholder:text-text-secondary-dark p-4 text-base font-normal leading-normal" placeholder="Confirm new password" type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} />
            </div>
          </label>
          {error && <p className="text-error text-sm font-medium px-1 mt-1">{error}</p>}
          {success && <p className="text-success text-sm font-medium px-1 mt-1">{success}</p>}
          <div className="mt-8">
            <button type="submit" className="flex w-full items-center justify-center rounded-xl bg-primary h-14 text-white text-base font-bold leading-normal shadow-lg shadow-primary/30">
              Reset Password
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
