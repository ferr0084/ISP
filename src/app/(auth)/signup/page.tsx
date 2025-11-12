'use client';

import Link from 'next/link';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function SignupPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    });

    if (error) {
      setError(error.message);
    } else {
      setSuccess('Please check your email to verify your account.');
    }
  };

  return (
    <div className="relative flex h-auto min-h-screen w-full flex-col font-display dark group/design-root overflow-x-hidden">
      <main className="flex flex-col grow justify-between items-center p-6">
        <div className="flex-shrink-0 w-full flex justify-start">
          <Link href="/login" className="flex items-center text-primary">
            <span className="material-symbols-outlined">arrow_back_ios_new</span>
          </Link>
        </div>
        <div className="flex flex-col items-center justify-center flex-grow py-8 w-full max-w-md">
          <div className="w-20 h-20 bg-primary rounded-full flex items-center justify-center mb-6">
            <span className="material-symbols-outlined text-white text-5xl">person_add</span>
          </div>
          <h1 className="text-slate-900 dark:text-white tracking-tight text-[32px] font-bold leading-tight pb-2">Create Account</h1>
          <p className="text-slate-600 dark:text-slate-300 text-base font-normal leading-normal pb-8">Let's get you started!</p>
          <form className="w-full space-y-4" onSubmit={handleSignup}>
            <input className="form-input w-full h-12 px-4 bg-input-light dark:bg-input-dark text-slate-900 dark:text-white rounded-lg border-none focus:ring-2 focus:ring-primary focus:ring-opacity-50 placeholder:text-slate-500 dark:placeholder:text-slate-400" placeholder="Full Name" type="text" value={fullName} onChange={(e) => setFullName(e.target.value)} />
            <input className="form-input w-full h-12 px-4 bg-input-light dark:bg-input-dark text-slate-900 dark:text-white rounded-lg border-none focus:ring-2 focus:ring-primary focus:ring-opacity-50 placeholder:text-slate-500 dark:placeholder:text-slate-400" placeholder="Email Address" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
            <input className="form-input w-full h-12 px-4 bg-input-light dark:bg-input-dark text-slate-900 dark:text-white rounded-lg border-none focus:ring-2 focus:ring-primary focus:ring-opacity-50 placeholder:text-slate-500 dark:placeholder:text-slate-400" placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
            {error && <p className="text-red-500 text-sm">{error}</p>}
            {success && <p className="text-green-500 text-sm">{success}</p>}
            <div className="flex px-4 py-3">
              <button type="submit" className="flex min-w-[84px] max-w-[480px] cursor-pointer items-center justify-center overflow-hidden rounded-lg h-12 px-5 flex-1 bg-primary text-white text-base font-bold leading-normal tracking-[0.015em]">
                <span className="truncate">Sign Up</span>
              </button>
            </div>
          </form>
          <div className="mt-4">
            <p className="text-slate-500 dark:text-slate-400 text-sm font-normal leading-normal text-center">Already have an account? <Link className="font-bold text-primary" href="/auth/login">Log In</Link></p>
          </div>
        </div>
      </main>
    </div>
  );
}
