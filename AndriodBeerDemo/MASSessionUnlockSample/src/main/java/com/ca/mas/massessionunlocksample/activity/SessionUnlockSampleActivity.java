/*
 * Copyright (c) 2016 CA. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 */
package com.ca.mas.massessionunlocksample.activity;

import android.app.Application;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TextInputEditText;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.ca.mas.foundation.MAS;
import com.ca.mas.foundation.MASCallback;
import com.ca.mas.foundation.MASRequest;
import com.ca.mas.foundation.MASResponse;
import com.ca.mas.foundation.MASSessionUnlockCallback;
import com.ca.mas.foundation.MASUser;
import com.ca.mas.massessionunlocksample.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.security.Key;
import java.util.ArrayList;
import java.util.List;

public class SessionUnlockSampleActivity extends AppCompatActivity {
    private final String TAG = SessionUnlockSampleActivity.class.getSimpleName();
    private RelativeLayout mContainer;
    private Button mLoginButton;
    private Button mInvokeButton;
    private TextInputLayout mUsernameInputLayout;
    private TextInputEditText mUsernameEditText;
    private TextInputLayout mPasswordInputLayout;
    private TextInputEditText mPasswordEditText;
    private Switch mLockSwitch;
    private TextView mProtectedContent;
    private ProgressBar mProgressBar;
    private int REQUEST_CODE = 0x1000;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Prevents screenshotting of content in Recents
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE);

        setContentView(R.layout.activity_session_unlock_sample);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setTitle(getTitle());

        mContainer = findViewById(R.id.container);
        mUsernameEditText = findViewById(R.id.edit_text_username);
        mUsernameInputLayout = findViewById(R.id.text_input_layout_username);
        mPasswordEditText = findViewById(R.id.edit_text_password);
        mPasswordInputLayout = findViewById(R.id.text_input_layout_password);
        mLoginButton = findViewById(R.id.login_button);
        mLockSwitch = findViewById(R.id.checkbox_lock);
        mProtectedContent = findViewById(R.id.data_text_view);
        mInvokeButton = findViewById(R.id.invoke_button);
        mProgressBar = findViewById(R.id.progressBar);


        mLoginButton.setOnClickListener(getLoginListener());
        mInvokeButton.setOnClickListener(getInvokeListener());
        mLockSwitch.setOnCheckedChangeListener(getLockListener(this));

        MAS.start(this, true);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                MASUser.getCurrentUser().unlockSession(getUnlockCallback(this));
            } else if (resultCode == RESULT_CANCELED) {
                mLockSwitch.setChecked(true);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (MASUser.getCurrentUser() == null) {
            onLogout();
        } else {
            onLogin();
            if (MASUser.getCurrentUser().isSessionLocked()) {
                mLockSwitch.setChecked(true);
            }
        }
    }

    private View.OnClickListener getLoginListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = mUsernameEditText.getEditableText().toString();
                String password = mPasswordEditText.getEditableText().toString();

                if (username.length() > 0 && password.length() > 0) {
                    mProgressBar.setVisibility(View.VISIBLE);
                    MASUser.login(username, password.toCharArray(), getLoginCallback());
                } else {
                    Snackbar.make(mContainer, "Invalid Log In Credentials", Snackbar.LENGTH_LONG).show();
                }
            }
        };
    }

    private View.OnClickListener getLogoutListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mProgressBar.setVisibility(View.VISIBLE);

                MASUser currentUser = MASUser.getCurrentUser();
                currentUser.logout(true,getLogoutCallback());
            }
        };
    }

    private View.OnClickListener getInvokeListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mProgressBar.setVisibility(View.VISIBLE);

                String path = "/protected/resource/products";
                Uri.Builder uriBuilder = new Uri.Builder().encodedPath(path);
                uriBuilder.appendQueryParameter("operation", "listProducts");
                uriBuilder.appendQueryParameter("pName2", "pValue2");

                MASRequest.MASRequestBuilder requestBuilder = new MASRequest.MASRequestBuilder(uriBuilder.build());
                requestBuilder.header("hName1", "hValue1");
                requestBuilder.header("hName2", "hValue2");
                MASRequest request = requestBuilder.get().build();

                MAS.invoke(request, getInvokeCallback());
            }
        };
    }

    private Switch.OnCheckedChangeListener getLockListener(final SessionUnlockSampleActivity activity) {
        return new Switch.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mProgressBar.setVisibility(View.VISIBLE);

                if (isChecked) {
                    MASUser.getCurrentUser().lockSession(getLockCallback());
                } else {
                    MASUser.getCurrentUser().unlockSession(getUnlockCallback(activity));
                }
            }
        };
    }

    private MASCallback<MASUser> getLoginCallback() {
        return new MASCallback<MASUser>() {
            @Override
            public void onSuccess(MASUser user) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onLogin();
                    }
                });
            }

            @Override
            public void onError(final Throwable e) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mProgressBar.setVisibility(View.GONE);
                        Snackbar.make(mContainer,e.getMessage(),Snackbar.LENGTH_LONG).show();
                    }
                });
            }
        };
    }

    private MASCallback<Void> getLogoutCallback() {
        return new MASCallback<Void>() {
            @Override
            public Handler getHandler() {
                return new Handler(Looper.getMainLooper());
            }

            @Override
            public void onSuccess(Void result) {
                onLogout();
            }

            @Override
            public void onError(Throwable e) {
                mProgressBar.setVisibility(View.GONE);
                Snackbar.make(mContainer, e.toString(), Snackbar.LENGTH_LONG).show();
            }
        };
    }

    private MASCallback<MASResponse<JSONObject>> getInvokeCallback() {
        return new MASCallback<MASResponse<JSONObject>>() {
            @Override
            public Handler getHandler() {
                return new Handler(Looper.getMainLooper());
            }

            @Override
            public void onSuccess(MASResponse<JSONObject> result) {
                onInvoke(result);
            }

            @Override
            public void onError(Throwable e) {
                mProgressBar.setVisibility(View.GONE);
                mProtectedContent.setText(R.string.invoke_session_locked);
                Log.e(TAG, e.getMessage());
            }
        };
    }

    private MASCallback<Void> getLockCallback() {
        mProgressBar.setVisibility(View.GONE);

        return new MASCallback<Void>() {
            @Override
            public void onSuccess(Void result) {
                onLock();
            }

            @Override
            public void onError(Throwable e) {
                Snackbar.make(mContainer, e.toString(), Snackbar.LENGTH_LONG).show();
            }
        };
    }

    private MASSessionUnlockCallback<Void> getUnlockCallback(final SessionUnlockSampleActivity activity) {
        return new MASSessionUnlockCallback<Void>() {
            @Override
            public void onUserAuthenticationRequired() {
                KeyguardManager keyguardManager = (KeyguardManager) activity.getSystemService(Application.KEYGUARD_SERVICE);
                Intent intent = keyguardManager.createConfirmDeviceCredentialIntent("Session Unlock", "Provide PIN or Fingerprint To unlock Session");
                activity.startActivityForResult(intent, REQUEST_CODE);
            }

            @Override
            public void onSuccess(Void result) {
                onUnLock();
            }

            @Override
            public void onError(Throwable e) {
                mProgressBar.setVisibility(View.GONE);
                Snackbar.make(mContainer, e.toString(), Snackbar.LENGTH_LONG).show();
            }
        };
    }

    private void onLogin() {
        mProgressBar.setVisibility(View.GONE);

        mInvokeButton.setVisibility(View.VISIBLE);
        mLockSwitch.setVisibility(View.VISIBLE);
        mLoginButton.setText(R.string.logout_button_text);
        mLoginButton.setOnClickListener(getLogoutListener());

        mUsernameInputLayout.setVisibility(View.GONE);
        mPasswordInputLayout.setVisibility(View.GONE);

        String textToSet = "Logged in as " + MASUser.getCurrentUser().getUserName();
        mProtectedContent.setText(textToSet);
    }

    private void onLogout() {
        mProgressBar.setVisibility(View.GONE);

        mInvokeButton.setVisibility(View.GONE);
        mLockSwitch.setVisibility(View.GONE);
        mLoginButton.setText(R.string.login_button_text);
        mLoginButton.setOnClickListener(getLoginListener());
        mProtectedContent.setText(R.string.protected_info);

        mUsernameInputLayout.setVisibility(View.VISIBLE);
        mPasswordInputLayout.setVisibility(View.VISIBLE);
    }

    private void onInvoke(MASResponse<JSONObject> result) {
        mProgressBar.setVisibility(View.GONE);

        try {
            List<String> objects = parseProductListJson(result.getBody().getContent());
            String objectString = "";
            int size = objects.size();
            for (int i = 0; i < size; i++) {
                objectString += objects.get(i);
                if (i != size - 1) {
                    objectString += "\n";
                }
            }

            mProtectedContent.setText(objectString);
        } catch (JSONException e) {

            Log.e(TAG, e.getMessage());
        }
    }

    private void onLock() {
        mProgressBar.setVisibility(View.GONE);
        mProtectedContent.setText(R.string.session_locked);
        Snackbar.make(mContainer, "Session Locked", Snackbar.LENGTH_LONG).show();
    }

    private void onUnLock() {
        mProgressBar.setVisibility(View.GONE);
        mProtectedContent.setText(R.string.session_unlocked);
        Snackbar.make(mContainer, "Session Unlocked", Snackbar.LENGTH_LONG).show();
    }

    private static List<String> parseProductListJson(JSONObject json) throws JSONException {
        try {
            List<String> objects = new ArrayList<>();
            JSONArray items = json.getJSONArray("products");
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = (JSONObject) items.get(i);
                Integer id = (Integer) item.get("id");
                String name = (String) item.get("name");
                String price = (String) item.get("price");
                objects.add(id + ": " + name + ", $" + price);
            }
            return objects;
        } catch (ClassCastException e) {
            throw (JSONException) new JSONException("Response JSON was not in the expected format").initCause(e);
        }
    }
}
